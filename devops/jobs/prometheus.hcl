job "prometheus" {
  datacenters = ["europe-paris"]
  namespace   = "${destination}"
  type        = "service"

  constraint {
    attribute = "$${attr.unique.hostname}"
    value     = "europe-paris-${destination}"
  }

  group "prometheus" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = 9090
      }
      port "thanos-grpc" {
        to = 10901
      }
      port "thanos-http" {
        to = 10902
      }
    }

    task "thanos-sidecar" {
      driver = "docker"
      user   = "root"

      config {
        image      = "thanosio/thanos:${thanos_docker_tag}"
        privileged = true
        args = [
          "sidecar",
          "--tsdb.path",
          "/prometheus",
          "--prometheus.url",
          "http://localhost:9090",
          "--objstore.config-file",
          "/etc/bucket.yml",
        ]
        volumes = [
          "/mnt/prometheus_data:/prometheus",
          "secrets/bucket.yml:/etc/bucket.yml",
        ]
        ports = ["thanos-grpc", "thanos-http"]
        extra_hosts = [
          "s3.docker.localhost:10.1.0.2"
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
        cpu    = 250
        memory = 128
      }

      service {
        provider = "nomad"
        name     = "thanos-sidecar-grpc"
        port     = "thanos-grpc"
      }

      service {
        provider = "nomad"
        name     = "thanos-sidecar-http"
        port     = "thanos-http"
        check {
          type     = "http"
          path     = "/-/ready"
          interval = "10s"
          timeout  = "2s"
        }
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }
    }

    task "prometheus" {
      driver = "docker"
      user   = "root"

      config {
        image      = "prom/prometheus:${prometheus_docker_tag}"
        privileged = true
        args = [
          "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles",
          "--web.enable-remote-write-receiver",
          "--storage.tsdb.retention.time=6h",
          "--storage.tsdb.retention.size=4GB",
          "--web.enable-lifecycle",
          "--storage.tsdb.max-block-duration=2h",
          "--storage.tsdb.min-block-duration=2h",
        ]
        ports = ["http"]
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
          "/mnt/prometheus_data:/prometheus",
          "/mnt/prometheus/rules:/etc/prometheus/rules",
          "/mnt/prometheus/scrape_configs:/etc/prometheus/scrape_configs"
        ]
      }

      template {
        data        = <<-EOF
global:
  evaluation_interval: 1m
  scrape_interval: 1m
  scrape_timeout: 10s
  external_labels:
    cluster: 'europe'
rule_files:
  - '/etc/prometheus/rules/*.yaml'
  - '/etc/prometheus/rules/*.yml'
scrape_config_files:
  - '/etc/prometheus/scrape_configs/*.yaml'
  - '/etc/prometheus/scrape_configs/*.yml'
EOF
        destination = "local/prometheus.yml"
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        provider = "nomad"
        name     = "prometheus"
        port     = "http"
        tags = [
          "metrics", "monitoring",
          "traefik.enable=true",
          "traefik.http.routers.prometheus.rule=Host(`prometheus.docker.localhost`)",
          "traefik.http.routers.prometheus.entrypoints=web",
          "traefik.http.services.prometheus.loadbalancer.passhostheader=true",
        ]
        check {
          type     = "http"
          path     = "/-/ready"
          interval = "10s"
          timeout  = "2s"
        }
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }
    }
  }
}
