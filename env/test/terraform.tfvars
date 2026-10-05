#########################################
# General
#########################################

project_name = "speshway"

environment = "test"

region = "ap-south-1"

#########################################
# VPC
#########################################

vpc_cidr = "10.0.0.0/16"

#########################################
# Public Subnets
#########################################

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

#########################################
# Private Subnets
#########################################

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

#########################################
# NAT count
#########################################

nat_gateway_count = 1

#########################################
# AZs
#########################################

availability_zone_indexes = [0, 1]
#########################################
# Vpc-Endpoint
#########################################

gateway_vpc_endpoints = [
  "s3"
]

interface_vpc_endpoints = [
  "ecr.api",
  "ecr.dkr"
]

vpc_endpoint_ingress_cidrs = [
  "10.0.0.0/16"
]
############################################
# IAM Configuration
############################################

iam_policies = {
  ###########################################
  # External Dns policy
  ############################################

  external_dns = {

    description = "ExternalDNS Route53 permissions"

    statements = [

      {
        sid = "ChangeRecords"

        actions = [
          "route53:ChangeResourceRecordSets"
        ]

        resources = [
          "arn:aws:route53:::hostedzone/*"
        ]
      },

      {
        sid = "ListHostedZones"

        actions = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]

        resources = [
          "*"
        ]
      }

    ]
  }
  ############################################
  # Fluent Bit CloudWatch Logs Policy
  ############################################

  fluent_bit_cloudwatch = {

    description = "Fluent Bit permissions to write Kubernetes application logs to CloudWatch"

    statements = [

      {
        sid = "CloudWatchLogs"

        actions = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]

        resources = [
          "arn:aws:logs:ap-south-1:179897609830:log-group:/aws/containerinsights/speshway-test-eks/application:*"
        ]
      }

    ]
  }
  ###########################################
  # AWS LB controller
  ############################################
  aws_load_balancer_controller = {
    description = "AWS Load Balancer Controller permissions"

    statements = [
      {
        sid = "EC2"

        actions = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:CreateTags",
          "ec2:DescribeRouteTables",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways"
        ]

        resources = ["*"]
      },

      {
        sid = "ELB"

        actions = [
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ]

        resources = ["*"]
      },

      {
        sid = "SecurityGroups"

        actions = [
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress"
        ]

        resources = ["*"]
      },

      {
        sid = "IAM"

        actions = [
          "iam:CreateServiceLinkedRole"
        ]

        resources = ["*"]
      }
    ]
  }

}
########################################
# IAM roles
##########################################
iam_roles = {

  ##########################################
  # EKS Cluster Role
  ##########################################

  eks_cluster = {

    name = "speshway-test-eks-cluster-role"

    description = "IAM role for the Amazon EKS control plane"

    trusted_services = [
      "eks.amazonaws.com"
    ]

    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    ]
  }

  ##########################################
  # EKS Managed Node Role
  ##########################################

  eks_node = {

    name = "speshway-test-eks-node-role"

    description = "IAM role for Amazon EKS managed worker nodes"

    trusted_services = [
      "ec2.amazonaws.com"
    ]

    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    ]

  }
  jenkins = {
    name = "speshway-test-jenkins-role"

    trusted_services = [
      "ec2.amazonaws.com"
    ]

    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
      "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
      "arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess",
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    ]

    create_instance_profile = true
  }

  nexus = {
    name = "speshway-test-nexus-role"

    trusted_services = [
      "ec2.amazonaws.com"
    ]

    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    ]

    create_instance_profile = true
  }

  sonarqube = {
    name = "speshway-test-sonarqube-role"

    trusted_services = [
      "ec2.amazonaws.com"
    ]

    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
      "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
    ]

    create_instance_profile = true
  }
  monitoring = {
    name = "speshway-test-monitoring-role"

    trusted_services = [
      "ec2.amazonaws.com"
    ]

    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
    ]

    create_instance_profile = true
  }
}
############################################
# KMS
############################################

kms_keys = {

  ecr = {

    description = "KMS key for ECR repositories"

    alias = "alias/speshway-test-ecr"

    administrators = [
      "arn:aws:iam::179897609830:role/Terraform-Execution-role"
    ]

    users = []

  }
  eks = {

    description = "KMS key for EKS Kubernetes secret encryption"

    alias = "alias/speshway-test-eks"

    administrators = [
      "arn:aws:iam::179897609830:role/Terraform-Execution-role"
    ]

    users = []

  }
  rds = {

    description = "KMS key for RDS secret encryption"

    alias = "alias/speshway-test-rds"

    administrators = [
      "arn:aws:iam::179897609830:role/Terraform-Execution-role"
    ]

    users = []

  }


}

############################################
# ECR
############################################

ecr_repositories = {
  images = {}
}
############################################
# EKS
############################################

eks_cluster_version = "1.31"

endpoint_private_access = true

endpoint_public_access = true

public_access_cidrs = ["13.214.140.224/32"]


eks_node_groups = {

  system = {

    instance_types = [

      "t3.large"

    ]

    capacity_type = "ON_DEMAND"

    min_size = 1

    max_size = 2

    desired_size = 1

    disk_size = 50

    labels = {

      workload = "system"

    }

    use_launch_template = true

  }

}

launch_templates = {
  system = {
    root_volume_size              = 50
    root_volume_type              = "gp3"
    delete_on_termination         = true
    encrypted                     = true
    additional_security_group_ids = []
  }
}
eks_access_entries = {
  terraform = {
    principal_arn = "arn:aws:iam::179897609830:role/Terraform-Execution-role"

    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

    access_scope = {
      type       = "cluster"
      namespaces = []
    }
    type = "STANDARD"
  }
  jenkins = {
    principal_arn = "arn:aws:iam::179897609830:role/speshway-test-jenkins-role"

    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

    access_scope = {
      type       = "cluster"
      namespaces = []
    }
    type = "STANDARD"
  }
  monitoring = {
    principal_arn = "arn:aws:iam::179897609830:role/speshway-test-monitoring-role"

    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

    access_scope = {
      type       = "cluster"
      namespaces = []
    }
    type = "STANDARD"
  }
  eks_user = {
    principal_arn = "arn:aws:iam::179897609830:user/eks-user"

    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

    access_scope = {
      type       = "cluster"
      namespaces = []
    }

    type = "STANDARD"
  }
}

eks_irsa_roles = {

  vpc-cni = {

    namespace = "kube-system"

    service_account = "aws-node"

    policy_arns = [
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    ]
  }

  aws-ebs-csi-driver = {

    namespace = "kube-system"

    service_account = "ebs-csi-controller-sa"

    policy_arns = [
      "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    ]
  }

  aws-load-balancer-controller = {

    namespace = "kube-system"

    service_account = "aws-load-balancer-controller"

    policy_names = [

      "aws_load_balancer_controller"

    ]

  }
  external-dns = {

    namespace = "external-dns"

    service_account = "external-dns"

    policy_names = [

      "external_dns"

    ]

  }
  ############################################
  # Fluent Bit
  ############################################
  fluent-bit = {

    namespace = "amazon-cloudwatch"

    service_account = "fluent-bit"

    policy_names = [
      "fluent_bit_cloudwatch"
    ]

  }
}

addons = {

  ##########################################
  # EKS Managed Add-ons
  ##########################################

  vpc-cni = {

    type = "eks"

    irsa_role = "vpc-cni"

  }

  coredns = {

    type = "eks"

  }

  kube-proxy = {

    type = "eks"

  }

  aws-ebs-csi-driver = {

    type = "eks"

    irsa_role = "aws-ebs-csi-driver"

  }

  ##########################################
  # Helm Add-ons
  ##########################################

  metrics-server = {

    type = "helm"

    namespace = "kube-system"

    repository = "https://kubernetes-sigs.github.io/metrics-server"

    chart = "metrics-server"

  }

  cert-manager = {

    type = "helm"

    namespace = "cert-manager"

    repository = "https://charts.jetstack.io"

    chart = "cert-manager"

    set = {

      installCRDs = true

    }

  }
  kube-state-metrics = {
    type       = "helm"
    namespace  = "monitoring"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart      = "kube-state-metrics"
    values = {
    service = {
      type     = "NodePort"
      nodePort = 30080
    }
  }
  }
  node-exporter = {
    type       = "helm"
    namespace  = "monitoring"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart      = "prometheus-node-exporter"

    set = {
      "service.port" = 9100

    }
  }

  external-dns = {

    type = "helm"

    irsa_role = "external-dns"

    namespace = "external-dns"

    repository = "https://kubernetes-sigs.github.io/external-dns"

    chart = "external-dns"

    set = {

      provider = "aws"

      policy = "sync"

      registry = "txt"

      txtOwnerId = "speshway-test"

      "serviceAccount.name" = "external-dns"

    }

  }


}

enable_karpenter = false

cluster_log_types = [

  "api",
  "audit",
  "authenticator",
  "controllerManager",
  "scheduler"

]

cluster_log_retention_in_days = 30

cluster_log_kms_key_arn = null
############################################
# LB controller
############################################
load_balancer_controller_helm_repository = "https://aws.github.io/eks-charts"

load_balancer_controller_chart_name = "aws-load-balancer-controller"

aws_load_balancer_controller_chart_version = "3.5.0"
############################################
# RDS
############################################
rds = {

  identifier = "crm-test-rds"

  engine = "mysql"

  engine_version = "8.0"

  parameter_group_family = "mysql8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  storage_type = "gp3"

  storage_encrypted = true

  database_name = "crm"

  master_username = "crmadmin"

  manage_master_user_password = true

  publicly_accessible = false

  multi_az = false

  backup_retention_period = 7

  backup_window = "03:00-04:00"

  maintenance_window = "sun:04:00-sun:05:00"

  deletion_protection = false

  skip_final_snapshot = true
}

############################################
# Platform
############################################
# =========================================================
# JENKINS
# =========================================================

jenkins_instance_type = "t3.medium"

jenkins_root_volume_size = 20

jenkins_data_volume_size = 50

jenkins_data_volume_type = "gp3"


# =========================================================
# NEXUS
# =========================================================

nexus_instance_type = "t3.medium"

nexus_root_volume_size = 20

nexus_data_volume_size = 100

nexus_data_volume_type = "gp3"


# =========================================================
# SONARQUBE
# =========================================================

sonarqube_instance_type = "t3.medium"

sonarqube_root_volume_size = 20

sonarqube_data_volumes = {
  sonarqube = {
    size        = 50
    type        = "gp3"
    encrypted   = true
    device_name = "/dev/sdf"
  }

  postgres = {
    size        = 30
    type        = "gp3"
    encrypted   = true
    device_name = "/dev/sdg"
  }
}


# =========================================================
# MONITORING
# =========================================================

enable_detailed_monitoring = false

# =========================================================
# Cloudwatch
# =========================================================
monitoring_alert_email = "ntharun@speshway.com"
############################################
# Fluent Bit
############################################

fluent_bit_helm_repository = "https://aws.github.io/eks-charts"

fluent_bit_chart_name = "aws-for-fluent-bit"

ifluent_bit_chart_version = "0.1.35"
# =========================================================
# prometheus
# =========================================================

prometheus_instance_type = "t3.medium"

prometheus_root_volume_size = 20

prometheus_data_volume_size = 100

prometheus_data_volume_type = "gp3"

