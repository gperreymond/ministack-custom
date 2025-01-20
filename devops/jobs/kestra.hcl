variable "kestra_docker_tag" {
  type    = string
  default = ""
}

variable "destination" {
  type    = string
  default = ""
}

variable "dnsname" {
  type    = string
  default = ""
}

job "kestra" {
  region      = "global"
  datacenters = ["*"]
  namespace   = var.destination
  type        = "service"
  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "${var.destination}"
  }
  update {
    stagger      = "30s"
    max_parallel = 1
  }
  group "kestra" {
    count = 1
    network {
      mode = "bridge"
      port "http" { to = 8080 }
      port "management" { to = 8081 }
    }
    service {
      name     = "${var.destination}-http"
      provider = "nomad"
      port     = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${var.destination}.rule=Host(`${var.dnsname}`)",
        "traefik.http.routers.${var.destination}.entrypoints=web",
        "traefik.http.services.${var.destination}.loadbalancer.passhostheader=true",
      ]
    }
    service {
      name     = "${var.destination}-management"
      provider = "nomad"
      port     = "management"
      tags = [
        "prometheus/scrape=true",
      ]
    }
    task "kestra" {
      driver = "docker"
      user   = "root"
      logs {
        max_files     = 1
        max_file_size = 5
      }
      config {
        image = "kestra/kestra:v${var.kestra_docker_tag}"
        args  = ["server", "standalone"]
        ports = ["http", "management"]
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
          "/tmp/kestra-wd:/tmp/kestra-wd",
          "local/application.yml:/app/confs/application.yml:ro",
        ]
      }
      template {
        data        = <<EOH
JVM_ARGS="-Xms1024m -Xmx1024m"
MICRONAUT_CONFIG_FILES="/app/confs/application.yml"
EOH
        destination = "local/config.env"
        env         = true
      }
      template {
        data        = <<-EOF
datasources:
  postgres:
    {{- with nomadVar "kestra/${var.destination}/configuration/postgres" }}
    url: 'jdbc:postgresql://{{ .host }}:{{ .port }}/{{ .database }}'
    driverClassName: 'org.postgresql.Driver'
    username: '{{ .username }}'
    password: '{{ .password }}'
    {{- end }}
kestra:
  tutorialFlows:
    enabled: false
  queue:
    type: 'postgres'
  tasks:
    tmpDir:
      path: /tmp/kestra-wd/tmp
  repository:
    type: 'postgres'
  storage:
    type: 'minio'
    minio:
      {{- with nomadVar "kestra/${var.destination}/configuration/minio" }}
      endpoint: '{{ .endpoint }}'
      port: '{{ .port }}'
      access-key: '{{ .access_key }}'
      secret-key: '{{ .secret_key }}'
      secure: '{{ .secure }}'
      bucket: '{{ .bucket }}'
      {{- end }}
EOF
        destination = "local/application.yml"
      }
      resources {
        cpu    = 500
        memory = 1024
      }
    }
  }
}