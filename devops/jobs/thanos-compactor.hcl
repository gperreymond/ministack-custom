job "thanos-compactor" {
  datacenters = ["europe-paris"]
  namespace   = "${destination}"
  type        = "service"

  constraint {
    attribute = "$${attr.unique.hostname}"
    value     = "europe-paris-${destination}"
  }

  group "thanos-compactor" {
    count = 1

    network {
      mode = "bridge"
      port "thanos-http" {
        to = 10902
      }
    }

    task "thanos-compactor" {
      driver = "docker"
      user   = "root"

      config {
        image      = "thanosio/thanos:${thanos_docker_tag}"
        privileged = true
        args = [
          "compact",
          "--data-dir=/data",
          "--objstore.config-file=/etc/bucket.yml",
          "--compact.concurrency=32",
          "--retention.resolution-raw=30d",
          "--retention.resolution-5m=120d",
          "--retention.resolution-1h=1y",
          "--consistency-delay=30m",
          "--wait",
          "--delete-delay=0",
        ]
        volumes = [
          "/mnt/thanos_compactor_data:/data",
          "secrets/bucket.yml:/etc/bucket.yml",
        ]
        ports = ["thanos-http"]
        extra_hosts = [
          "s3.docker.localhost:10.1.0.2",
        ]
      }

      template {
        data        = <<-EOF
{{- with nomadVar "monitoring/thanos-store/configuration/bucket" }}
type: s3
config:
  bucket: {{ .bucket }}
  insecure: true
  endpoint: {{ .endpoint }}
  access_key: {{ .access_key }}
  secret_key: {{ .secret_key }}
{{- end }}
EOF
        destination = "secrets/bucket.yml"
      }

      resources {
        cpu    = 1000
        memory = 2048
      }

      service {
        provider = "nomad"
        name     = "thanos-compactor-http"
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
          "traefik.http.routers.thanos-compactor.rule=Host(`thanos-compactor.docker.localhost`)",
          "traefik.http.routers.thanos-compactor.entrypoints=web",
          "traefik.http.services.thanos-compactor.loadbalancer.passhostheader=true",
        ]
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }
    }
  }
}
