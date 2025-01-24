job "netbirt-agents" {
  region      = "global"
  datacenters = ["*"]
  namespace   = "${destination}"
  type        = "system"
  update {
    stagger      = "30s"
    max_parallel = 1
  }
  group "netbirt-agent" {
    network {
      mode = "host"
    }
    task "netbirt-agent" {
      driver = "docker"
      logs {
        max_files     = 1
        max_file_size = 5
      }
      config {
        image      = "netbirdio/netbird:${docker_tag}"
        cap_add    = ["net_admin"]
        hostname   = "$${attr.unique.hostname}"
        privileged = true
        ipc_mode   = "host"
        volumes = [
          "/mnt/netbird_client_data:/etc/netbird"
        ]
      }
      template {
        data        = <<EOH
{{- with nomadVar "netbird/configuration/nomad-agent" }}
NB_SETUP_KEY="{{ .agent_setupkey }}"
{{- end }}
    EOH
        destination = "local/config.env"
        env         = true
      }
    }
  }
}
