data "local_file" "kestra_clients" {
  filename = "${path.module}/files/data.yaml"
}
