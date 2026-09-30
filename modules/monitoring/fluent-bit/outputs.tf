############################################
# Fluent Bit Outputs
############################################

output "helm_release_name" {

  description = "Fluent Bit Helm release name"

  value = helm_release.this.name

}

output "namespace" {

  description = "Fluent Bit Kubernetes namespace"

  value = var.namespace

}

output "service_account_name" {

  description = "Fluent Bit Kubernetes service account"

  value = var.service_account_name

}

output "irsa_role_arn" {

  description = "Fluent Bit IRSA role ARN"

  value = var.irsa_role_arn

}

output "log_group_name" {

  description = "CloudWatch Log Group used by Fluent Bit"

  value = aws_cloudwatch_log_group.this.name

}
