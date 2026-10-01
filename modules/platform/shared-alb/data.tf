# ============================================================
# EXISTING PLATFORM EC2 INSTANCES
# ============================================================

data "aws_instance" "jenkins" {
  instance_id = "i-07d704025918e926b"
}

data "aws_instance" "nexus" {
  instance_id = "i-03c2776443798c6f5"
}

data "aws_instance" "sonarqube" {
  instance_id = "i-0cecd07e484a41ef1"
}

data "aws_instance" "grafana" {
  instance_id = "i-035b6e1029c0c4865"
}

