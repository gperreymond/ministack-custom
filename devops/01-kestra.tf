resource "nomad_namespace" "kestra_system" {
  name = "kestra-system"
}

resource "random_password" "kestra_postgres_password" {
  length  = 32
  special = false
}

resource "nomad_variable" "kestra_system" {
  path      = "kestra/secrets"
  namespace = nomad_namespace.kestra_system.name
  items = {
    kestra_postgres_password = random_password.kestra_postgres_password.result
  }
}

resource "null_resource" "kestra" {
  depends_on = [
    nomad_namespace.kestra_system,
    random_password.kestra_postgres_password,
  ]
}