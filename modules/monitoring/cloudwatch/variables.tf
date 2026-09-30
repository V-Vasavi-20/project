############################################
# Project
############################################

variable "project_name" {
  description = "Project name"
  type        = string
}

############################################
# Environment
############################################

variable "environment" {
  description = "Environment name"
  type        = string
}

############################################
# Alert Email
############################################

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
  default     = null
}

############################################
# Generic CloudWatch Alarms
############################################

variable "alarms" {
  description = "Generic CloudWatch alarms"

  type = map(object({

    alarm_name = string

    alarm_description = optional(string)

    namespace = string

    metric_name = string

    statistic = optional(
      string,
      "Average"
    )

    period = optional(
      number,
      300
    )

    evaluation_periods = optional(
      number,
      2
    )

    threshold = number

    comparison_operator = string

    dimensions = optional(
      map(string),
      {}
    )

    treat_missing_data = optional(
      string,
      "missing"
    )

    enabled = optional(
      bool,
      true
    )

  }))

  default = {}
}

############################################
# Application Logs
############################################

variable "application_log_group_name" {
  description = "CloudWatch Log Group receiving Fluent Bit application logs"
  type        = string
  default     = null
}

############################################
# Dashboard
############################################

variable "dashboard_widgets" {
  description = "Generic CloudWatch dashboard widgets"

  type    = any
  default = []
}
