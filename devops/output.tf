output "clients" {
  value = { for client in local.clients : client.hostname => {
    address = "http://${client.dnsname}"
    volumes = [
      docker_volume.nomad_client[client.hostname].name,
    ]
    }
  }
}
