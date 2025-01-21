data "local_file" "kestra_clients" {
  filename = "${path.module}/../kestra-clients.yaml"
}
