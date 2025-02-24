job "grafana" {
  datacenters = ["europe-paris"]
  namespace   = "${destination}"
  type        = "service"

  constraint {
    attribute = "$${attr.unique.hostname}"
    value     = "europe-paris-${destination}"
  }

  group "grafana" {
    count = 1

    network {
      mode = "bridge"
      port "grafana-http" {
        to = 3000
      }
    }

    task "grafana" {
      driver = "docker"
      user   = "root"

      config {
        image      = "grafana/grafana:${grafana_docker_tag}"
        privileged = true
        ports      = ["grafana-http"]
        volumes = [
          "secrets/grafana.ini:/etc/grafana/grafana.ini"
        ]
        extra_hosts = [
          "rds-postgres.docker.localhost:10.1.0.2",
          "thanos-query-frontend.docker.localhost:10.1.0.2",
        ]
      }

      template {
        env         = true
        data        = <<-EOF
GF_USERS_ALLOW_SIGN_UP=false
GF_INSTALL_PLUGINS=grafana-clock-panel
{{- with nomadVar "monitoring/grafana/configuration/admin" }}
GF_SECURITY_ADMIN_PASSWORD={{ .password }}
{{- end }}
EOF
        destination = "secrets/.env"
      }

      template {
        data        = <<-EOF
{{- with nomadVar "monitoring/grafana/configuration/postgres" }}
[database]
type=postgres
host={{ .host }}:{{ .port }}
name={{ .database }}
user={{ .username }}
password={{ .password }}
{{- end }}
EOF
        destination = "secrets/grafana.ini"
      }

      resources {
        cpu    = 125
        memory = 128
      }

      service {
        provider = "nomad"
        name     = "grafana-http"
        port     = "grafana-http"
        check {
          type     = "http"
          path     = "/api/health"
          interval = "10s"
          timeout  = "2s"
        }
        tags = [
          "metrics", "monitoring",
          "traefik.enable=true",
          "traefik.http.routers.grafana.rule=Host(`grafana.docker.localhost`)",
          "traefik.http.routers.grafana.entrypoints=web",
          "traefik.http.services.grafana.loadbalancer.passhostheader=true",
        ]
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }
    }
  }
}
