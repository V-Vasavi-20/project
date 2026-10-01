resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type          = var.sonarqube_instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.sonarqube.id]

  iam_instance_profile = var.iam_instance_profile_name

  user_data = templatefile("${path.module}/user_data.sh", {
    sonarqube_volume_id = aws_ebs_volume.data["sonarqube"].id
    postgres_volume_id   = aws_ebs_volume.data["postgres"].id

    sonarqube_mount_path = var.sonarqube_mount_path
    postgres_mount_path  = var.postgres_mount_path

    sonarqube_image     = var.sonarqube_image
    sonarqube_container = var.sonarqube_container
    sonarqube_port      = var.sonarqube_port

    postgres_image     = var.postgres_image
    postgres_container = var.postgres_container
    postgres_user      = var.postgres_user
    postgres_db        = var.postgres_db
    postgres_port      = var.postgres_port

    postgres_uid = var.postgres_uid
    postgres_gid = var.postgres_gid

    sonarqube_uid = var.sonarqube_uid
    sonarqube_gid = var.sonarqube_gid

    docker_network = var.docker_network

    secret_name        = var.secret_name
    secret_description = var.secret_description

    postgres_password_file = var.postgres_password_file

    compose_directory = var.compose_directory
    compose_file      = var.compose_file
    compose_env_file   = var.compose_env_file

    postgres_health_interval      = var.postgres_health_interval
    postgres_health_timeout       = var.postgres_health_timeout
    postgres_health_retries       = var.postgres_health_retries
    postgres_health_start_period  = var.postgres_health_start_period
    container_start_wait          = var.container_start_wait

    vm_max_map_count = var.vm_max_map_count
    fs_file_max      = var.fs_file_max

    aws_region = var.aws_region

    docker_compose = file("${path.module}/docker-compose.yml")
  })
  user_data_replace_on_change = true

  monitoring = var.enable_detailed_monitoring

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
  tags = local.sonarqube_tags
}
