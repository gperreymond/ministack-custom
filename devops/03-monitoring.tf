resource "nomad_namespace" "monitoring_system" {
  name = "monitoring-system"

  depends_on = [
    null_resource.postgres,
  ]
}

resource "nomad_job" "prometheus" {
  jobspec = templatefile("${path.module}/jobs/prometheus.hcl", {
    destination = nomad_namespace.monitoring_system.id,
    docker_tag  = "v3.1.0"
  })
  purge_on_destroy = true

  depends_on = [
    nomad_namespace.monitoring_system,
  ]
}

resource "null_resource" "monitoring" {
  depends_on = [
    // parent
    null_resource.postgres,
    // resources
    nomad_namespace.monitoring_system,
    nomad_job.prometheus,
  ]
}