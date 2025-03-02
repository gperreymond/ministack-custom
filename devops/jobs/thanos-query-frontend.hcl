job "thanos-query-frontend" {
  datacenters = ["europe-paris"]
  namespace   = "${destination}"
  type        = "service"

  constraint {
    attribute = "$${attr.unique.hostname}"
    value     = "europe-paris-${destination}"
  }

  group "thanos-query-frontend" {
    count = 1

    network {
      mode = "bridge"
      port "thanos-http" {
        to = 9090
      }
    }

    task "thanos-query-frontend" {
      driver = "docker"
      user   = "root"

      config {
        image      = "thanosio/thanos:${thanos_docker_tag}"
        privileged = true
        args = [
          "query-frontend",
          "--http-address=0.0.0.0:9090",
          "--query-frontend.downstream-url=$${THANOS_QUERY_ENDPOINT_HTTP}",
        ]
        ports = ["thanos-http"]
      }

      template {
        env         = true
        data        = <<-EOF
THANOS_QUERY_ENDPOINT_HTTP=http://{{- range nomadService "thanos-query-http" }}{{ .Address }}:{{ .Port }}{{- end }}
EOF
        destination = "local/.env"
      }

      resources {
        cpu    = 125
        memory = 128
      }

      service {
        provider = "nomad"
        name     = "thanos-query-frontend-http"
        port     = "thanos-http"
        check {
          type     = "http"
          path     = "/-/ready"
          interval = "10s"
          timeout  = "2s"
        }
        tags = [
          "metrics", "monitoring",
          "traefik.enable=true",
          "traefik.http.routers.thanos-query-frontend.rule=Host(`thanos-query-frontend.docker.localhost`)",
          "traefik.http.routers.thanos-query-frontend.entrypoints=web",
          "traefik.http.services.thanos-query-frontend.loadbalancer.passhostheader=true",
        ]
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }
    }
  }
}
