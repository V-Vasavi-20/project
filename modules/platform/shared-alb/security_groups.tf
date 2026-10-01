resource "aws_security_group" "shared_alb" {
  name        = "${var.project_name}-${var.environment}-shared-alb-sg"
  description = "Security group for shared internet-facing ALB"
  vpc_id      = var.vpc_id

  tags = merge(
    local.alb_tags,
    {
      Name = "${local.alb_name}-sg"
    }
  )
}

# Jenkins - ALB listener 8080
resource "aws_vpc_security_group_ingress_rule" "jenkins" {
  security_group_id = aws_security_group.shared_alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.jenkins_port
  to_port     = var.jenkins_port
  ip_protocol = "tcp"

  description = "Allow internet traffic to Jenkins"
}

# Nexus - ALB listener 8081
resource "aws_vpc_security_group_ingress_rule" "nexus" {
  security_group_id = aws_security_group.shared_alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.nexus_port
  to_port     = var.nexus_port
  ip_protocol = "tcp"

  description = "Allow internet traffic to Nexus"
}

# SonarQube - ALB listener 9000
resource "aws_vpc_security_group_ingress_rule" "sonarqube" {
  security_group_id = aws_security_group.shared_alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.sonarqube_port
  to_port     = var.sonarqube_port
  ip_protocol = "tcp"

  description = "Allow internet traffic to SonarQube"
}
# Grafana - ALB listener 3000
resource "aws_vpc_security_group_ingress_rule" "grafana" {

  security_group_id = aws_security_group.shared_alb.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = var.grafana_port
  to_port = var.grafana_port
  ip_protocol = "tcp"

  description = "Allow Grafana traffic"
}
# ALB outbound
resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.shared_alb.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  description = "Allow ALB outbound traffic"
}
