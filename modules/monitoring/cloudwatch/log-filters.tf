############################################
# Metric Filter - Application Errors
############################################

resource "aws_cloudwatch_log_metric_filter" "application_errors" {

  count = var.application_log_group_name != null ? 1 : 0

  name = "${var.project_name}-${var.environment}-application-errors"

  log_group_name = var.application_log_group_name

  pattern = "?ERROR ?Error ?error"

  metric_transformation {

    name = "ApplicationErrors"

    namespace = "${var.project_name}/${var.environment}"

    value = "1"

    default_value = "0"
  }
}
