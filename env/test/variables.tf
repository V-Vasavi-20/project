############################################
# Project Information
############################################

variable "project_name" {
  description = "Project name"
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "Project name cannot be empty."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition = contains(
      ["test", "prod"],
      var.environment
    )

    error_message = "Environment must be one of: test, or prod."
  }
}

############################################
# AWS Region
############################################

variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string

}

############################################
# Networking
############################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zone_indexes" {
  description = "Availability Zones used by the VPC"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}
variable "nat_gateway_count" {
  type = number
}

############################################
# Common Tags
############################################

variable "common_tags" {
  description = "Additional tags applied to resources"
  type        = map(string)

  default = {}
}
############################################
# VPC ENDPOINTS
############################################
variable "gateway_vpc_endpoints" {
  description = "Gateway VPC endpoints"
  type        = set(string)
  default     = []
}

variable "interface_vpc_endpoints" {
  description = "Interface VPC endpoints"
  type        = set(string)
  default     = []
}

variable "vpc_endpoint_ingress_cidrs" {
  description = "CIDRs allowed to access interface VPC endpoints"
  type        = set(string)
  default     = []
}
############################################
# IAM Configuration
############################################

variable "iam_roles" {
  description = "IAM roles configuration for the IAM module"

  type = map(object({
    name = string

    description = optional(string, null)

    trusted_services = optional(list(string), [])

    trusted_role_arns = optional(list(string), [])

    managed_policy_arns = optional(list(string), [])

    policy_names = optional(list(string), [])

    create_instance_profile = optional(bool, false)

    tags = optional(map(string), {})
  }))

  default = {}
}
variable "iam_policies" {
  description = "Reusable customer-managed IAM policies"

  type = map(object({
    description = optional(
      string,
      null
    )

    statements = list(object({
      sid = optional(string)

      effect = optional(
        string,
        "Allow"
      )

      actions = list(string)

      resources = list(string)

      conditions = optional(
        map(object({
          test     = string
          variable = string
          values   = list(string)
        })),
        {}
      )
    }))
  }))

  default = {}
}
############################################
# KMS Keys
############################################

variable "kms_keys" {

  description = "Configuration for customer-managed KMS keys"

  type = map(object({

    description = string

    alias = string

    administrators = optional(
      list(string),
      []
    )

    users = optional(
      list(string),
      []
    )

    deletion_window_in_days = optional(
      number,
      30
    )

    enable_key_rotation = optional(
      bool,
      true
    )

    tags = optional(
      map(string),
      {}
    )

  }))

  default = {}

}
############################################
# ECR Repositories
############################################

variable "ecr_repositories" {

  description = "Configuration for ECR repositories"

  type = map(object({

    repository_name = optional(
      string,
      null
    )

    image_tag_mutability = optional(
      string,
      "IMMUTABLE"
    )

    force_delete = optional(
      bool,
      true
    )

    encryption_type = optional(
      string,
      "KMS"
    )

    kms_key_arn = optional(
      string,
      null
    )

    lifecycle = optional(object({

      enabled = optional(
        bool,
        true
      )

      max_image_count = optional(
        number,
        30
      )

      untagged_image_days = optional(
        number,
        14
      )

    }), {})

    tags = optional(
      map(string),
      {}
    )

  }))

  default = {}

}
############################################
# EKS
############################################

variable "eks_cluster_version" {

  description = "Kubernetes version for EKS"

  type = string

}
variable "endpoint_private_access" {

  description = "Enable private EKS API endpoint access"

  type = bool

  default = true

}

variable "endpoint_public_access" {

  description = "Enable public EKS API endpoint access"

  type = bool

  default = false

}

variable "public_access_cidrs" {

  description = "CIDRs allowed to access the public EKS API endpoint"

  type = list(string)

  default = []

}
############################################
# EKS Access Entries
############################################
variable "eks_access_entries" {
  description = "EKS access entries and their associated policies"
  type = map(object({
    principal_arn = string

    policy_arn = optional(
      string,
      "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    )

    access_scope = optional(object({
      type       = string
      namespaces = optional(list(string), [])
      }), {
      type       = "cluster"
      namespaces = []
    })

    type = optional(string, "STANDARD")
  }))

  default = {}
}


variable "eks_node_groups" {

  description = "EKS managed node-group configuration"

  type = map(object({

    instance_types = list(string)

    capacity_type = optional(
      string,
      "ON_DEMAND"
    )

    min_size = number

    max_size = number

    desired_size = number

    disk_size = optional(
      number,
      50
    )

    labels = optional(
      map(string),
      {}
    )

    taints = optional(
      map(object({

        key = string

        value = optional(string)

        effect = string

      })),
      {}
    )

    use_launch_template = optional(
      bool,
      false
    )

  }))

  default = {}

}

variable "eks_irsa_roles" {

  description = "IRSA roles for EKS add-ons"

  type = map(object({

    namespace = string

    service_account = string

    policy_arns = optional(list(string), [])

    policy_names = optional(list(string), [])

  }))

  default = {}

}
############################################
# Launch Templates
############################################

variable "launch_templates" {

  description = "Optional launch-template configuration"

  type = map(object({

    root_volume_size = optional(number, 50)

    root_volume_type = optional(string, "gp3")

    delete_on_termination = optional(bool, true)

    encrypted = optional(bool, true)

    additional_security_group_ids = optional(list(string), [])
    user_data = optional(string, null)

  }))

  default = {}

}


############################################
# EKS & Helm Add-ons
############################################

variable "addons" {

  description = "EKS managed add-ons and Helm add-ons"

  type = map(object({

    ##########################################
    # Common
    ##########################################

    type = string

    irsa_role = optional(string)

    ##########################################
    # EKS
    ##########################################

    addon_version = optional(string)

    resolve_conflicts_on_create = optional(
      string,
      "OVERWRITE"
    )

    resolve_conflicts_on_update = optional(
      string,
      "OVERWRITE"
    )

    ##########################################
    # Helm
    ##########################################

    namespace = optional(string)

    repository = optional(string)

    chart = optional(string)

    version = optional(string)

    create_namespace = optional(
      bool,
      true
    )

    values = optional(
      any,
      {}
    )

    set = optional(
      map(string),
      {}
    )

  }))

  default = {}

}

variable "enable_karpenter" {

  type = bool

  default = false

}

variable "karpenter_node_classes" {

  type = any

  default = {}

}

variable "karpenter_node_pools" {

  type = any

  default = {}

}

variable "cluster_log_types" {

  type = list(string)

}

variable "cluster_log_retention_in_days" {

  type = number

}

variable "cluster_log_kms_key_arn" {

  type = string

  default = null

}
############################################
# LBcontroller
############################################
variable "load_balancer_controller_helm_repository" {

  description = "Helm repository for AWS Load Balancer Controller"

  type = string

  default = "https://aws.github.io/eks-charts"

}
variable "load_balancer_controller_chart_name" {

  description = "AWS Load Balancer Controller Helm chart"

  type = string

  default = "aws-load-balancer-controller"

}
variable "aws_load_balancer_controller_chart_version" {

  description = "AWS Load Balancer Controller Helm chart version"

  type = string

}
############################################
# RDS
############################################

variable "rds" {
  description = "RDS configuration"

  type = object({

    identifier = string

    engine = string

    engine_version = string

    instance_class = string

    allocated_storage = number

    storage_type = string

    storage_encrypted = bool

    database_name = string

    master_username = string

    manage_master_user_password = bool

    master_user_secret_kms_arn = optional(string)

    publicly_accessible = bool

    multi_az = bool

    backup_retention_period = number

    backup_window = string

    maintenance_window = string

    deletion_protection = bool

    skip_final_snapshot = bool

    parameter_group_family = string
  })

}
############################################
# Platform
############################################

# =========================================================
# ALB Security Group
# =========================================================

variable "alb_security_group_id" {
  description = "Security group ID of the shared ALB"
  type        = string
  default     = null
}

# =========================================================
# Jenkins EC2
# =========================================================

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.medium"
}

variable "jenkins_root_volume_size" {
  description = "Jenkins root EBS volume size in GB"
  type        = number
  default     = 20
}

variable "jenkins_data_volume_size" {
  description = "Jenkins persistent data EBS volume size in GB"
  type        = number
  default     = 50
}

variable "jenkins_data_volume_type" {
  description = "Jenkins persistent data EBS volume type"
  type        = string
  default     = "gp3"
}


# =========================================================
# Nexus EC2
# =========================================================

variable "nexus_instance_type" {
  description = "EC2 instance type for Nexus"
  type        = string
  default     = "t3.medium"
}

variable "nexus_root_volume_size" {
  description = "Nexus root EBS volume size in GB"
  type        = number
  default     = 20
}

variable "nexus_data_volume_size" {
  description = "Nexus persistent data EBS volume size in GB"
  type        = number
  default     = 100
}

variable "nexus_data_volume_type" {
  description = "Nexus persistent data EBS volume type"
  type        = string
  default     = "gp3"
}


# =========================================================
# SonarQube EC2
# =========================================================

variable "sonarqube_instance_type" {
  description = "EC2 instance type for SonarQube"
  type        = string
  default     = "t3.medium"
}

variable "sonarqube_version" {
  description = "SonarQube version"
  type        = string
  default     = "25.8.0.112058"
}

variable "sonarqube_root_volume_size" {
  description = "SonarQube root EBS volume size in GB"
  type        = number
  default     = 20
}

variable "sonarqube_data_volumes" {
  description = "Persistent EBS volumes for SonarQube and PostgreSQL"

  type = map(object({
    size        = number
    type        = string
    encrypted   = bool
    device_name = string
  }))
}

# =========================================================
# Monitoring
# =========================================================

variable "enable_detailed_monitoring" {
  description = "Enable EC2 detailed monitoring"
  type        = bool
  default     = false
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention period"
  type        = number
  default     = 30
}

#########################################
#Cloudwatch
#########################################
variable "monitoring_alert_email" {
  description = "Email address for CloudWatch monitoring alerts"
  type        = string
}
############################################
# Fluent Bit
############################################

variable "fluent_bit_helm_repository" {

  description = "Fluent Bit Helm repository"

  type = string

  default = "https://aws.github.io/eks-charts"

}

variable "fluent_bit_chart_name" {

  description = "Fluent Bit Helm chart"

  type = string

  default = "aws-for-fluent-bit"

}

variable "fluent_bit_chart_version" {

  description = "Fluent Bit Helm chart version"

  type = string

  default = null

}
