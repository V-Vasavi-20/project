resource "aws_ebs_volume" "prometheus_data" {
  availability_zone = data.aws_subnet.prometheus.availability_zone

  size = var.data_volume_size

  type = var.data_volume_type

  encrypted = true

  tags = merge(
    local.prometheus_tags,
    {
      Name = "${local.prometheus_name}-data"
      Type = "Monitoring-Data"
    }
  )
}

resource "aws_volume_attachment" "prometheus_data" {
  device_name = "/dev/sdf"

  volume_id = aws_ebs_volume.prometheus_data.id

  instance_id = aws_instance.prometheus.id

  stop_instance_before_detaching = true
}
