resource "nomad_namespace" "monitoring_system" {
  name = "monitoring-system"

  depends_on = [
    null_resource.postgres,
  ]
}

resource "nomad_variable" "grafana_postgres_configuration" {
  path      = "monitoring/grafana/configuration/postgres"
  namespace = nomad_namespace.monitoring_system.id
  items = {
    host     = "${var.provider_postgres_host}"
    port     = "${var.provider_postgres_port}"
    database = "grafana"
    username = "grafana"
    password = "${random_password.grafana_postgres.result}"
  }

  depends_on = [
    nomad_namespace.monitoring_system,
  ]
}

resource "random_password" "grafana_admin_password" {
  length  = 32
  special = false

  depends_on = [
    nomad_namespace.monitoring_system,
  ]
}
resource "nomad_variable" "grafana_admin_configuration" {
  path      = "monitoring/grafana/configuration/admin"
  namespace = nomad_namespace.monitoring_system.id
  items = {
    password = "${random_password.grafana_admin_password.result}"
  }

  depends_on = [
    nomad_namespace.monitoring_system,
  ]
}

resource "nomad_variable" "thanos_store_configuration" {
  path      = "monitoring/thanos-store/configuration/bucket"
  namespace = nomad_namespace.monitoring_system.id
  items = {
    bucket     = minio_s3_bucket.thanos_stone.bucket
    endpoint   = var.provider_minio_host
    access_key = minio_iam_service_account.thanos_stone.access_key
    secret_key = minio_iam_service_account.thanos_stone.secret_key
  }

  depends_on = [
    nomad_namespace.monitoring_system,
  ]
}

resource "nomad_job" "prometheus" {
  jobspec = templatefile("${path.module}/jobs/prometheus.hcl", {
    destination           = nomad_namespace.monitoring_system.id,
    prometheus_docker_tag = "v3.2.1"
    thanos_docker_tag     = "v0.37.2"
  })
  purge_on_destroy = true

  depends_on = [
    nomad_variable.grafana_postgres_configuration,
    nomad_variable.thanos_store_configuration,
  ]
}

resource "nomad_job" "thanos_store" {
  jobspec = templatefile("${path.module}/jobs/thanos-store.hcl", {
    destination       = nomad_namespace.monitoring_system.id,
    thanos_docker_tag = "v0.37.2"
  })
  purge_on_destroy = true

  depends_on = [
    nomad_job.prometheus,
  ]
}

resource "nomad_job" "thanos_query" {
  jobspec = templatefile("${path.module}/jobs/thanos-query.hcl", {
    destination       = nomad_namespace.monitoring_system.id,
    thanos_docker_tag = "v0.37.2"
  })
  purge_on_destroy = true

  depends_on = [
    nomad_job.thanos_store,
  ]
}

resource "nomad_job" "thanos_query_frontend" {
  jobspec = templatefile("${path.module}/jobs/thanos-query-frontend.hcl", {
    destination       = nomad_namespace.monitoring_system.id,
    thanos_docker_tag = "v0.37.2"
  })
  purge_on_destroy = true

  depends_on = [
    nomad_job.thanos_query,
  ]
}

resource "nomad_job" "thanos_compactor" {
  jobspec = templatefile("${path.module}/jobs/thanos-compactor.hcl", {
    destination       = nomad_namespace.monitoring_system.id,
    thanos_docker_tag = "v0.37.2"
  })
  purge_on_destroy = true

  depends_on = [
    nomad_job.thanos_query_frontend,
  ]
}

resource "nomad_job" "grafana" {
  jobspec = templatefile("${path.module}/jobs/grafana.hcl", {
    destination        = nomad_namespace.monitoring_system.id,
    grafana_docker_tag = "11.5.2"
  })
  purge_on_destroy = true

  depends_on = [
    nomad_job.thanos_compactor,
    nomad_variable.grafana_postgres_configuration,
    random_password.grafana_admin_password,
  ]
}

resource "null_resource" "monitoring" {
  depends_on = [
    // parent
    null_resource.postgres,
    // resources
    nomad_namespace.monitoring_system,
    random_password.grafana_admin_password,
    nomad_variable.grafana_postgres_configuration,
    nomad_variable.thanos_store_configuration,
    nomad_variable.grafana_admin_configuration,
    nomad_job.prometheus,
    nomad_job.thanos_store,
    nomad_job.thanos_query,
    nomad_job.thanos_query_frontend,
    nomad_job.thanos_compactor,
    nomad_job.grafana,
  ]
}