resource "random_password" "kestra_postgres" {
  for_each = { for client in local.clients : client.hostname => client }

  length  = 32
  special = false

  depends_on = [
    null_resource.minio,
  ]
}

resource "postgresql_role" "kestra_postgres" {
  for_each = { for client in local.clients : client.hostname => client }

  name     = each.value.hostname
  login    = true
  password = random_password.kestra_postgres[each.value.hostname].result

  depends_on = [
    random_password.kestra_postgres,
  ]
}

resource "postgresql_database" "kestra_postgres" {
  for_each = { for client in local.clients : client.hostname => client }

  name  = each.value.hostname
  owner = postgresql_role.kestra_postgres[each.value.hostname].name

  depends_on = [
    postgresql_role.kestra_postgres,
  ]
}

resource "null_resource" "postgres" {
  depends_on = [
    // parent
    null_resource.minio,
    // resources
    random_password.kestra_postgres,
    postgresql_role.kestra_postgres,
    postgresql_database.kestra_postgres,
  ]
}