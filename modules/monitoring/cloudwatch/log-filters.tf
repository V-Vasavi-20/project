resource "aws_cloudwatch_log_metric_filter" "application_errors" {
  count = var.application_log_group_name != null ? 1 : 0

  name = "${var.project_name}-${var.environment}-application-errors"

  log_group_name = var.application_log_group_name

  pattern = "{ ($.kubernetes.namespace_name = \"admin\" || $.kubernetes.namespace_name = \"auth\" || $.kubernetes.namespace_name = \"customer\" || $.kubernetes.namespace_name = \"employee\" || $.kubernetes.namespace_name = \"gateway\" || $.kubernetes.namespace_name = \"hr\" || $.kubernetes.namespace_name = \"task\" || $.kubernetes.namespace_name = \"user\") && ($.log = \"*ERROR*\" || $.log = \"*Error*\" || $.log = \"*error*\") }"

  metric_transformation {
    name          = "ApplicationErrors"
    namespace     = "${var.project_name}/${var.environment}"
    value         = "1"
    default_value = "0"
  }
}
