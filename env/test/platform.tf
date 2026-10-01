module "jenkins" {
  source = "../../modules/platform/jenkins"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.region

  vpc_id            = module.networking.vpc_id
  private_subnet_id = module.networking.private_subnet_ids[0]

  iam_instance_profile_name = module.iam.instance_profile_names["jenkins"]

  jenkins_instance_type = var.jenkins_instance_type

  root_volume_size = var.jenkins_root_volume_size
  data_volume_size = var.jenkins_data_volume_size
  data_volume_type = var.jenkins_data_volume_type

  enable_detailed_monitoring = var.enable_detailed_monitoring

  common_tags = var.common_tags

  alb_security_group_id = module.shared_alb.security_group_id
}


module "nexus" {
  source = "../../modules/platform/nexus"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.region

  vpc_id            = module.networking.vpc_id
  private_subnet_id = module.networking.private_subnet_ids[1]

  iam_instance_profile_name = module.iam.instance_profile_names["nexus"]

  nexus_instance_type = var.nexus_instance_type

  root_volume_size = var.nexus_root_volume_size
  data_volume_size = var.nexus_data_volume_size
  data_volume_type = var.nexus_data_volume_type

  enable_detailed_monitoring = var.enable_detailed_monitoring

  common_tags = var.common_tags

  alb_security_group_id = module.shared_alb.security_group_id
}


module "sonarqube" {
  source = "../../modules/platform/sonarqube"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.region

  vpc_id            = module.networking.vpc_id
  private_subnet_id = module.networking.private_subnet_ids[0]

  iam_instance_profile_name = module.iam.instance_profile_names["sonarqube"]

  sonarqube_instance_type = var.sonarqube_instance_type

  root_volume_size = var.sonarqube_root_volume_size
  data_volumes     = var.sonarqube_data_volumes

  enable_detailed_monitoring = var.enable_detailed_monitoring

  common_tags = var.common_tags

  alb_security_group_id = module.shared_alb.security_group_id
}
module "shared_alb" {
  source = "../../modules/platform/shared-alb"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.region

  vpc_id = module.networking.vpc_id

  public_subnet_ids = module.networking.public_subnet_ids

  common_tags = var.common_tags
}
