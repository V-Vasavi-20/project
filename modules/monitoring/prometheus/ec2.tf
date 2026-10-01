resource "aws_instance" "prometheus" {
  ami = data.aws_ssm_parameter.amazon_linux_2023_ami.value

  instance_type = var.prometheus_instance_type

  subnet_id = var.private_subnet_id

  vpc_security_group_ids = [
    aws_security_group.prometheus.id
  ]

  iam_instance_profile = var.iam_instance_profile_name

  user_data = file("${path.module}/user_data.sh")

  user_data_replace_on_change = true

  monitoring = var.enable_detailed_monitoring

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = local.prometheus_tags
}
