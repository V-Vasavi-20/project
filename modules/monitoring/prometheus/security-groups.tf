resource "aws_security_group" "prometheus" {
  name = "${var.project_name}-${var.environment}-monitoring-sg"

  description = "Security group for Prometheus and Grafana monitoring EC2"

  vpc_id = var.vpc_id

  tags = merge(
    local.prometheus_tags,
    {
      Name = "${local.prometheus_name}-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "grafana_from_alb" {
  security_group_id = aws_security_group.prometheus.id

  referenced_security_group_id = var.alb_security_group_id

  from_port = var.grafana_port

  to_port = var.grafana_port

  ip_protocol = "tcp"

  description = "Allow Grafana traffic from shared ALB"
}

resource "aws_vpc_security_group_egress_rule" "prometheus_outbound" {
  security_group_id = aws_security_group.prometheus.id

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"

  description = "Allow monitoring outbound traffic through NAT"
}
