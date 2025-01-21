resource "docker_image" "hashibase" {
  name = "ghcr.io/gperreymond/hashibase:base-1.0.0"

  depends_on = [
    null_resource.postgres,
  ]
}

resource "docker_volume" "nomad_client" {
  for_each = { for client in local.clients : client.hostname => client }

  name = "kestra_nomad_client_${each.value.hostname}_data"

  depends_on = [
    docker_image.hashibase,
  ]
}

resource "docker_container" "nomad_client" {
  for_each = { for client in local.clients : client.hostname => client }

  name     = each.value.hostname
  image    = docker_image.hashibase.name
  hostname = each.value.hostname
  env = [
    "MINISTACK=true",
    "NOMAD_VERSION=1.9.5",
  ]

  depends_on = [
    docker_volume.nomad_client,
  ]
}

# resource "nomad_namespace" "kestra" {
#   for_each = { for client in local.clients : client.hostname => client }

#   name = each.value.hostname

#   depends_on = [
#     docker_image.hashibase,
#   ]
# }

# resource "nomad_variable" "kestra_minio_configuration" {
#   for_each = { for client in local.clients : client.hostname => client }

#   path      = "kestra/${each.value.hostname}/configuration/minio"
#   namespace = nomad_namespace.kestra[each.value.hostname].id
#   items = {
#     endpoint   = "${var.provider_minio_host}"
#     port       = "${var.provider_minio_port}"
#     access_key = "${minio_iam_service_account.kestra[each.value.hostname].access_key}"
#     secret_key = "${minio_iam_service_account.kestra[each.value.hostname].secret_key}"
#     secure     = "false"
#     bucket     = each.value.hostname
#   }

#   depends_on = [
#     nomad_namespace.kestra,
#   ]
# }

# resource "nomad_variable" "kestra_postgres_configuration" {
#   for_each = { for client in local.clients : client.hostname => client }

#   path      = "kestra/${each.value.hostname}/configuration/postgres"
#   namespace = nomad_namespace.kestra[each.value.hostname].id
#   items = {
#     host     = "${var.provider_postgres_host}"
#     port     = "${var.provider_postgres_port}"
#     database = "${each.value.hostname}"
#     username = "${each.value.hostname}"
#     password = "${random_password.kestra_postgres[each.value.hostname].result}"
#   }

#   depends_on = [
#     nomad_namespace.kestra,
#   ]
# }

# resource "nomad_job" "kestra" {
#   for_each = { for client in local.clients : client.hostname => client }

#   jobspec          = file("${path.module}/jobs/kestra.hcl")
#   purge_on_destroy = true

#   hcl2 {
#     vars = {
#       destination       = nomad_namespace.kestra[each.value.hostname].id,
#       kestra_docker_tag = "0.20.12"
#       dnsname           = each.value.dnsname
#     }
#   }

#   depends_on = [
#     nomad_variable.kestra_minio_configuration,
#     nomad_variable.kestra_postgres_configuration,
#   ]
# }

resource "null_resource" "kestra" {
  depends_on = [
    // parent
    null_resource.postgres,
    // resources
    docker_image.hashibase,
    docker_volume.nomad_client,
    docker_container.nomad_client,
    # nomad_namespace.kestra,
    # nomad_variable.kestra_minio_configuration,
    # nomad_variable.kestra_postgres_configuration,
    # nomad_job.kestra,
  ]
}
