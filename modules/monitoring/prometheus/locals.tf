locals {
  prometheus_name = "${var.project_name}-${var.environment}-monitoring"

  prometheus_tags = merge(
    var.common_tags,
    {
      Name    = local.prometheus_name
      Service = "Prometheus-Grafana"
    }
  )
}
