output "instance_id" {
  description = "Monitoring EC2 instance ID"
  value       = aws_instance.prometheus.id
}

output "private_ip" {
  description = "Monitoring EC2 private IP address"
  value       = aws_instance.prometheus.private_ip
}

output "security_group_id" {
  description = "Monitoring security group ID"
  value       = aws_security_group.prometheus.id
}

output "grafana_port" {
  description = "Grafana application port"
  value       = var.grafana_port
}

output "prometheus_port" {
  description = "Prometheus application port"
  value       = var.prometheus_port
}

output "cloudwatch_log_group_name" {
  description = "Monitoring CloudWatch log group name"
  value       = aws_cloudwatch_log_group.prometheus.name
}

output "data_volume_id" {
  description = "Persistent monitoring data EBS volume ID"
  value       = aws_ebs_volume.prometheus_data.id
}

output "iam_policy_arn" {
  description = "Monitoring IAM policy ARN"
  value       = aws_iam_policy.prometheus.arn
}
