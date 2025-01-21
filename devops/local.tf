locals {
  clients = yamldecode(data.local_file.kestra_clients.content).clients
}
