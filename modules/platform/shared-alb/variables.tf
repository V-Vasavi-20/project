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
  description = "VPC ID where the shared ALB is deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the internet-facing ALB"
  type        = list(string)
}

variable "jenkins_port" {
  description = "Jenkins application port"
  type        = number
  default     = 8080
}

variable "nexus_port" {
  description = "Nexus application port"
  type        = number
  default     = 8081
}

variable "sonarqube_port" {
  description = "SonarQube application port"
  type        = number
  default     = 9000
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
}
variable "grafana_port" {
  description = "Grafana application port"
  type        = number
  default     = 3000
}

