variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where monitoring EC2 is deployed"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for monitoring EC2"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the shared ALB"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile created by the generic IAM module"
  type        = string
}

variable "prometheus_instance_type" {
  description = "EC2 instance type for Prometheus and Grafana"
  type        = string
}

variable "root_volume_size" {
  description = "Root OS volume size in GB"
  type        = number
}

variable "data_volume_size" {
  description = "Persistent monitoring data volume size in GB"
  type        = number
}

variable "data_volume_type" {
  description = "EBS volume type for monitoring data"
  type        = string
}

variable "prometheus_port" {
  description = "Prometheus application port"
  type        = number
  default     = 9090
}

variable "grafana_port" {
  description = "Grafana application port"
  type        = number
  default     = 3000
}

variable "enable_detailed_monitoring" {
  description = "Enable EC2 detailed monitoring"
  type        = bool
  default     = false
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention period"
  type        = number
  default     = 30
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
}
