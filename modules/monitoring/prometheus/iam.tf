resource "aws_iam_policy" "prometheus" {
  name = "${var.project_name}-${var.environment}-monitoring-policy"

  description = "AWS permissions required by Prometheus and Grafana monitoring server"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "CloudWatchMetrics"
        Effect = "Allow"

        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]

        Resource = "*"
      }
    ]
  })

  tags = local.prometheus_tags
}
