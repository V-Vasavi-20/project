output "alb_arn_suffix" {
  description = "ALB ARN suffix used by CloudWatch metrics"
  value       = aws_lb.shared.arn_suffix
}
output "alb_id" {
  description = "Shared ALB ID"
  value       = aws_lb.shared.id
}

output "alb_arn" {
  description = "Shared ALB ARN"
  value       = aws_lb.shared.arn
}

output "alb_dns_name" {
  description = "DNS name of the shared ALB"
  value       = aws_lb.shared.dns_name
}

output "security_group_id" {
  description = "Shared ALB security group ID"
  value       = aws_security_group.shared_alb.id
}

output "jenkins_target_group_arn" {
  description = "Jenkins target group ARN"
  value       = aws_lb_target_group.jenkins.arn
}

output "nexus_target_group_arn" {
  description = "Nexus target group ARN"
  value       = aws_lb_target_group.nexus.arn
}

output "sonarqube_target_group_arn" {
  description = "SonarQube target group ARN"
  value       = aws_lb_target_group.sonarqube.arn
}
output "grafana_target_group_arn" {

  description = "Grafana target group ARN"

  value = aws_lb_target_group.grafana.arn
}
