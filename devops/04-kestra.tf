resource "local_file" "kestra_nomad_client" {
  for_each = { for client in local.clients : client.hostname => client }

  content  = <<-EOF
name: 'kestra'
datacenter: 'europe-paris'

network:
  external:
    enabled: true
    name: 'kestra'

services:
  nomad:
    enabled: true
    config:
      client:
        retry_join:
          - 'europe-paris-nomad-server-1'
          - 'europe-paris-nomad-server-2'
          - 'europe-paris-nomad-server-3'
    clients:
      - name: '${each.value.hostname}'
        loop_index: ${each.value.loop_index}
EOF
  filename = "${var.root_path}/../../../configurations/clients/${each.value.hostname}/cluster.yaml"

  depends_on = [
    null_resource.monitoring,
  ]
}

resource "nomad_namespace" "kestra" {
  for_each = { for client in local.clients : client.hostname => client }

  name = each.value.hostname

  depends_on = [
    local_file.kestra_nomad_client,
  ]
}

resource "nomad_variable" "kestra_minio_configuration" {
  for_each = { for client in local.clients : client.hostname => client }

  path      = "kestra/${each.value.hostname}/configuration/minio"
  namespace = nomad_namespace.kestra[each.value.hostname].id
  items = {
    endpoint   = "${var.provider_minio_host}"
    port       = "${var.provider_minio_port}"
    access_key = "${minio_iam_service_account.kestra[each.value.hostname].access_key}"
    secret_key = "${minio_iam_service_account.kestra[each.value.hostname].secret_key}"
    secure     = "false"
    bucket     = each.value.hostname
  }

  depends_on = [
    nomad_namespace.kestra,
  ]
}

resource "nomad_variable" "kestra_postgres_configuration" {
  for_each = { for client in local.clients : client.hostname => client }

  path      = "kestra/${each.value.hostname}/configuration/postgres"
  namespace = nomad_namespace.kestra[each.value.hostname].id
  items = {
    host     = "${var.provider_postgres_host}"
    port     = "${var.provider_postgres_port}"
    database = "${each.value.hostname}"
    username = "${each.value.hostname}"
    password = "${random_password.kestra_postgres[each.value.hostname].result}"
  }

  depends_on = [
    nomad_namespace.kestra,
  ]
}

resource "nomad_job" "kestra" {
  for_each = { for client in local.clients : client.hostname => client }

  jobspec = templatefile("${path.module}/jobs/kestra.hcl", {
    destination = nomad_namespace.kestra[each.value.hostname].id,
    docker_tag  = "v0.20.14"
    dnsname     = each.value.dnsname
    traefik_ip  = var.traefik_ip
  })
  purge_on_destroy = true

  depends_on = [
    nomad_variable.kestra_minio_configuration,
    nomad_variable.kestra_postgres_configuration,
  ]
}

resource "null_resource" "kestra" {
  depends_on = [
    // parent
    null_resource.monitoring,
    // resources
    local_file.kestra_nomad_client,
    nomad_namespace.kestra,
    nomad_variable.kestra_minio_configuration,
    nomad_variable.kestra_postgres_configuration,
    nomad_job.kestra,
  ]
}
