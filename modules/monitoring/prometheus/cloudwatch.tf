resource "aws_cloudwatch_log_group" "prometheus" {
  name = "/${var.project_name}/${var.environment}/monitoring"

  retention_in_days = var.cloudwatch_log_retention_days

  tags = merge(
    local.prometheus_tags,
    {
      Name = "${local.prometheus_name}-logs"
    }
  )
}
