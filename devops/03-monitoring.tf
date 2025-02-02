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

resource "nomad_job" "prometheus" {
  jobspec = templatefile("${path.module}/jobs/prometheus.hcl", {
    destination = nomad_namespace.monitoring_system.id,
    docker_tag  = "v3.1.0"
  })
  purge_on_destroy = true

  depends_on = [
    nomad_variable.grafana_postgres_configuration,
  ]
}

resource "null_resource" "monitoring" {
  depends_on = [
    // parent
    null_resource.postgres,
    // resources
    nomad_namespace.monitoring_system,
    nomad_variable.grafana_postgres_configuration,
    nomad_job.prometheus,
  ]
}