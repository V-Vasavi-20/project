# ============================================================
# SHARED INTERNET-FACING ALB
# ============================================================

resource "aws_lb" "shared" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"

  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.shared_alb.id]

  tags = local.alb_tags
}


# ============================================================
# JENKINS TARGET GROUP
# ============================================================

resource "aws_lb_target_group" "jenkins" {
  name     = "${var.project_name}-${var.environment}-jenkins"
  port     = var.jenkins_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/login"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = merge(
    local.alb_tags,
    {
      Service = "Jenkins"
    }
  )
}

resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = data.aws_instance.jenkins.id
  port             = var.jenkins_port
}


# ============================================================
# NEXUS TARGET GROUP
# ============================================================

resource "aws_lb_target_group" "nexus" {
  name     = "${var.project_name}-${var.environment}-nexus"
  port     = var.nexus_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = merge(
    local.alb_tags,
    {
      Service = "Nexus"
    }
  )
}

resource "aws_lb_target_group_attachment" "nexus" {
  target_group_arn = aws_lb_target_group.nexus.arn
  target_id        = data.aws_instance.nexus.id
  port             = var.nexus_port
}


# ============================================================
# SONARQUBE TARGET GROUP
# ============================================================

resource "aws_lb_target_group" "sonarqube" {
  name     = "${var.project_name}-${var.environment}-sonarqube"
  port     = var.sonarqube_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/api/system/status"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = merge(
    local.alb_tags,
    {
      Service = "SonarQube"
    }
  )
}

resource "aws_lb_target_group_attachment" "sonarqube" {
  target_group_arn = aws_lb_target_group.sonarqube.arn
  target_id        = data.aws_instance.sonarqube.id
  port             = var.sonarqube_port
}
# ============================================================
# GRAFANA TARGET GROUP
# ============================================================
resource "aws_lb_target_group" "grafana" {

  name = "${var.project_name}-${var.environment}-grafana"

  port = var.grafana_port

  protocol = "HTTP"

  vpc_id = var.vpc_id

  target_type = "instance"

  health_check {
    enabled = true

    protocol = "HTTP"

    path = "/api/health"

    port = "traffic-port"

    healthy_threshold = 3

    unhealthy_threshold = 3

    timeout = 5

    interval = 30
  }

  tags = merge(
    local.alb_tags,
    {
      Service = "Grafana"
    }
  )
}
resource "aws_lb_target_group_attachment" "grafana" {

  target_group_arn = aws_lb_target_group.grafana.arn

  target_id = data.aws_instance.grafana.id

  port = var.grafana_port
}

# ============================================================
# JENKINS LISTENER
# ALB:8080 → Jenkins:8080
# ============================================================

resource "aws_lb_listener" "jenkins" {
  load_balancer_arn = aws_lb.shared.arn
  port              = var.jenkins_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}


# ============================================================
# NEXUS LISTENER
# ALB:8081 → Nexus:8081
# ============================================================

resource "aws_lb_listener" "nexus" {
  load_balancer_arn = aws_lb.shared.arn
  port              = var.nexus_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexus.arn
  }
}


# ============================================================
# SONARQUBE LISTENER
# ALB:9000 → SonarQube:9000
# ============================================================

resource "aws_lb_listener" "sonarqube" {
  load_balancer_arn = aws_lb.shared.arn
  port              = var.sonarqube_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sonarqube.arn
  }
}
# ============================================================
# GRAFANA LISTENER

resource "aws_lb_listener" "grafana" {

  load_balancer_arn = aws_lb.shared.arn

  port = var.grafana_port

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.grafana.arn
  }
}
