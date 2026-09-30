############################################
# Project Information
############################################

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

############################################
# AWS
############################################

variable "region" {
  description = "AWS region"
  type        = string
}

############################################
# EKS
############################################

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "irsa_role_arn" {
  description = "Existing Fluent Bit IRSA role ARN created by the EKS module"
  type        = string
}

############################################
# Fluent Bit Kubernetes
############################################

variable "namespace" {
  description = "Kubernetes namespace for Fluent Bit"
  type        = string
  default     = "amazon-cloudwatch"
}

variable "service_account_name" {
  description = "Kubernetes service account name"
  type        = string
  default     = "fluent-bit"
}

############################################
# CloudWatch
############################################

variable "log_group_name" {
  description = "CloudWatch Log Group for Kubernetes application logs"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch application log retention period"
  type        = number
  default     = 30
}

############################################
# Helm
############################################

variable "helm_repository" {
  description = "AWS EKS Helm repository"
  type        = string
  default     = "https://aws.github.io/eks-charts"
}

variable "chart_name" {
  description = "Fluent Bit Helm chart name"
  type        = string
  default     = "aws-for-fluent-bit"
}

variable "chart_version" {
  description = "Fluent Bit Helm chart version"
  type        = string
  default     = null
}
