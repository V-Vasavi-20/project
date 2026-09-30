data "aws_lbs" "ingress" {
  tags = {
    "elbv2.k8s.aws/cluster" = module.eks.cluster_name
  }
}

data "aws_lb" "ingress" {
  for_each = toset(data.aws_lbs.ingress.arns)

  arn = each.value
}

module "cloudwatch" {
  source = "../../modules/monitoring/cloudwatch"

  environment = "test"

  alert_email = var.monitoring_alert_email

  alarms = merge(

    # ============================================================
    # RDS
    # ============================================================

    {
      rds_cpu = {
        alarm_name        = "test-rds-high-cpu"
        alarm_description = "RDS CPU utilization is above 80 percent"

        namespace   = "AWS/RDS"
        metric_name = "CPUUtilization"

        statistic           = "Average"
        period              = 300
        evaluation_periods  = 2
        comparison_operator = "GreaterThanThreshold"
        threshold           = 80

        dimensions = {
          DBInstanceIdentifier = module.rds.db_instance_identifier
        }
      }

      rds_connections = {
        alarm_name        = "test-rds-high-connections"
        alarm_description = "RDS database connections are high"

        namespace   = "AWS/RDS"
        metric_name = "DatabaseConnections"

        statistic           = "Average"
        period              = 300
        evaluation_periods  = 2
        comparison_operator = "GreaterThanThreshold"
        threshold           = 80

        dimensions = {
          DBInstanceIdentifier = module.rds.db_instance_identifier
        }
      }

      rds_free_storage = {
        alarm_name        = "test-rds-low-free-storage"
        alarm_description = "RDS free storage space is below 10 GiB"

        namespace   = "AWS/RDS"
        metric_name = "FreeStorageSpace"

        statistic           = "Minimum"
        period              = 300
        evaluation_periods  = 2
        comparison_operator = "LessThanThreshold"

        # 10 GiB
        threshold = 10737418240

        dimensions = {
          DBInstanceIdentifier = module.rds.db_instance_identifier
        }
      }
    },

    # ============================================================
    # SHARED ALB
    # ============================================================

    {
      shared_alb_5xx = {
        alarm_name        = "test-shared-alb-5xx"
        alarm_description = "Shared ALB is returning HTTP 5XX responses"

        namespace   = "AWS/ApplicationELB"
        metric_name = "HTTPCode_ELB_5XX_Count"

        statistic           = "Sum"
        period              = 300
        evaluation_periods  = 2
        comparison_operator = "GreaterThanThreshold"
        threshold           = 10

        dimensions = {
          LoadBalancer = module.shared_alb.alb_arn_suffix
        }

        treat_missing_data = "missing"
      }

      shared_alb_latency = {
        alarm_name        = "test-shared-alb-high-latency"
        alarm_description = "Shared ALB target response time is above 2 seconds"

        namespace   = "AWS/ApplicationELB"
        metric_name = "TargetResponseTime"

        statistic           = "Average"
        period              = 300
        evaluation_periods  = 2
        comparison_operator = "GreaterThanThreshold"
        threshold           = 2

        dimensions = {
          LoadBalancer = module.shared_alb.alb_arn_suffix
        }

        treat_missing_data = "missing"
      }
    },

    # ============================================================
    # EKS CONTROL PLANE
    # ============================================================

    {
      eks_api_5xx = {
        alarm_name        = "test-eks-api-server-5xx"
        alarm_description = "EKS API server is returning HTTP 5XX responses"

        namespace   = "AWS/EKS"
        metric_name = "apiserver_request_total_5XX"

        statistic           = "Sum"
        period              = 300
        evaluation_periods  = 2
        comparison_operator = "GreaterThanThreshold"
        threshold           = 0

        dimensions = {
          ClusterName = module.eks.cluster_name
        }

        treat_missing_data = "missing"
      }

      eks_api_429 = {
        alarm_name        = "test-eks-api-server-429"
        alarm_description = "EKS API server is returning HTTP 429 responses"

        namespace   = "AWS/EKS"
        metric_name = "apiserver_request_total_429"

        statistic           = "Sum"
        period              = 300
        evaluation_periods  = 2
        comparison_operator = "GreaterThanThreshold"
        threshold           = 10

        dimensions = {
          ClusterName = module.eks.cluster_name
        }

        treat_missing_data = "missing"
      }

      eks_pending_pods = {
        alarm_name        = "test-eks-pending-pods"
        alarm_description = "EKS scheduler has pending pods"

        namespace   = "AWS/EKS"
        metric_name = "scheduler_pending_pods"

        statistic           = "Sum"
        period              = 300
        evaluation_periods  = 2
        comparison_operator = "GreaterThanThreshold"
        threshold           = 0

        dimensions = {
          ClusterName = module.eks.cluster_name
        }

        treat_missing_data = "missing"
      }

      eks_unschedulable_pods = {
        alarm_name        = "test-eks-unschedulable-pods"
        alarm_description = "EKS scheduler is encountering unschedulable pods"

        namespace   = "AWS/EKS"
        metric_name = "scheduler_schedule_attempts_UNSCHEDULABLE"

        statistic           = "Sum"
        period              = 300
        evaluation_periods  = 2
        comparison_operator = "GreaterThanThreshold"
        threshold           = 0

        dimensions = {
          ClusterName = module.eks.cluster_name
        }

        treat_missing_data = "missing"
      }
    },

    # ============================================================
    # INGRESS ALB
    # Dynamically created by AWS Load Balancer Controller
    # ============================================================

    merge([
      for name, alb in data.aws_lb.ingress : {

        "ingress_${name}_5xx" = {
          alarm_name = "test-ingress-${name}-5xx"

          alarm_description = "Ingress ALB ${name} is returning HTTP 5XX responses"

          namespace   = "AWS/ApplicationELB"
          metric_name = "HTTPCode_ELB_5XX_Count"

          statistic           = "Sum"
          period              = 300
          evaluation_periods  = 2
          comparison_operator = "GreaterThanThreshold"
          threshold           = 10

          dimensions = {
            LoadBalancer = alb.arn_suffix
          }

          treat_missing_data = "missing"
        }

        "ingress_${name}_latency" = {
          alarm_name = "test-ingress-${name}-high-latency"

          alarm_description = "Ingress ALB ${name} target response time is above 2 seconds"

          namespace   = "AWS/ApplicationELB"
          metric_name = "TargetResponseTime"

          statistic           = "Average"
          period              = 300
          evaluation_periods  = 2
          comparison_operator = "GreaterThanThreshold"
          threshold           = 2

          dimensions = {
            LoadBalancer = alb.arn_suffix
          }

          treat_missing_data = "missing"
        }
      }
    ]...)
  )

  # ============================================================
  # GENERIC DASHBOARD
  # ============================================================

  dashboard_widgets = concat(

    # ------------------------------------------------------------
    # HEADER
    # ------------------------------------------------------------

    [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2

        properties = {
          markdown = "# Speshway Test Environment Monitoring"
        }
      },

      # ----------------------------------------------------------
      # SHARED ALB 5XX
      # ----------------------------------------------------------

      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6

        properties = {
          title  = "Shared ALB - ELB 5XX"
          region = "ap-south-1"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_5XX_Count",
              "LoadBalancer",
              module.shared_alb.alb_arn_suffix
            ]
          ]

          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },

      # ----------------------------------------------------------
      # SHARED ALB LATENCY
      # ----------------------------------------------------------

      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 6

        properties = {
          title  = "Shared ALB - Target Response Time"
          region = "ap-south-1"

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              module.shared_alb.alb_arn_suffix
            ]
          ]

          period = 300
          stat   = "Average"
          view   = "timeSeries"
        }
      },

      # ----------------------------------------------------------
      # RDS CPU
      # ----------------------------------------------------------

      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 8
        height = 6

        properties = {
          title  = "RDS CPU"
          region = "ap-south-1"

          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              "DBInstanceIdentifier",
              module.rds.db_instance_identifier
            ]
          ]

          period = 300
          stat   = "Average"
          view   = "timeSeries"
        }
      },

      # ----------------------------------------------------------
      # RDS CONNECTIONS
      # ----------------------------------------------------------

      {
        type   = "metric"
        x      = 8
        y      = 8
        width  = 8
        height = 6

        properties = {
          title  = "RDS Connections"
          region = "ap-south-1"

          metrics = [
            [
              "AWS/RDS",
              "DatabaseConnections",
              "DBInstanceIdentifier",
              module.rds.db_instance_identifier
            ]
          ]

          period = 300
          stat   = "Average"
          view   = "timeSeries"
        }
      },

      # ----------------------------------------------------------
      # RDS FREE STORAGE
      # ----------------------------------------------------------

      {
        type   = "metric"
        x      = 16
        y      = 8
        width  = 8
        height = 6

        properties = {
          title  = "RDS Free Storage"
          region = "ap-south-1"

          metrics = [
            [
              "AWS/RDS",
              "FreeStorageSpace",
              "DBInstanceIdentifier",
              module.rds.db_instance_identifier
            ]
          ]

          period = 300
          stat   = "Minimum"
          view   = "timeSeries"
        }
      },

      # ----------------------------------------------------------
      # EKS API 5XX
      # ----------------------------------------------------------

      {
        type   = "metric"
        x      = 0
        y      = 14
        width  = 8
        height = 6

        properties = {
          title  = "EKS API Server 5XX"
          region = "ap-south-1"

          metrics = [
            [
              "AWS/EKS",
              "apiserver_request_total_5XX",
              "ClusterName",
              module.eks.cluster_name
            ]
          ]

          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },

      # ----------------------------------------------------------
      # EKS API 429
      # ----------------------------------------------------------

      {
        type   = "metric"
        x      = 8
        y      = 14
        width  = 8
        height = 6

        properties = {
          title  = "EKS API Server 429"
          region = "ap-south-1"

          metrics = [
            [
              "AWS/EKS",
              "apiserver_request_total_429",
              "ClusterName",
              module.eks.cluster_name
            ]
          ]

          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },

      # ----------------------------------------------------------
      # EKS PENDING PODS
      # ----------------------------------------------------------

      {
        type   = "metric"
        x      = 16
        y      = 14
        width  = 8
        height = 6

        properties = {
          title  = "EKS Pending Pods"
          region = "ap-south-1"

          metrics = [
            [
              "AWS/EKS",
              "scheduler_pending_pods",
              "ClusterName",
              module.eks.cluster_name
            ]
          ]

          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },

      # ----------------------------------------------------------
      # EKS API REQUEST RATE
      # ----------------------------------------------------------

      {
        type   = "metric"
        x      = 0
        y      = 20
        width  = 8
        height = 6

        properties = {
          title  = "EKS API Request Rate"
          region = "ap-south-1"

          metrics = [
            [
              "AWS/EKS",
              "apiserver_request_total",
              "ClusterName",
              module.eks.cluster_name
            ]
          ]

          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },

      # ----------------------------------------------------------
      # EKS API EXECUTING SEATS
      # ----------------------------------------------------------

      {
        type   = "metric"
        x      = 8
        y      = 20
        width  = 8
        height = 6

        properties = {
          title  = "EKS API Executing Seats"
          region = "ap-south-1"

          metrics = [
            [
              "AWS/EKS",
              "apiserver_flowcontrol_current_executing_seats",
              "ClusterName",
              module.eks.cluster_name
            ]
          ]

          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },

      # ----------------------------------------------------------
      # EKS UNSCHEDULABLE ATTEMPTS
      # ----------------------------------------------------------

      {
        type   = "metric"
        x      = 16
        y      = 20
        width  = 8
        height = 6

        properties = {
          title  = "EKS Unschedulable Attempts"
          region = "ap-south-1"

          metrics = [
            [
              "AWS/EKS",
              "scheduler_schedule_attempts_UNSCHEDULABLE",
              "ClusterName",
              module.eks.cluster_name
            ]
          ]

          period = 300
          stat   = "Sum"
          view   = "timeSeries"
        }
      },

      # ----------------------------------------------------------
      # EKS ETCD SIZE
      # ----------------------------------------------------------

      {
        type   = "metric"
        x      = 0
        y      = 26
        width  = 12
        height = 6

        properties = {
          title  = "EKS etcd Database Size"
          region = "ap-south-1"

          metrics = [
            [
              "AWS/EKS",
              "etcd_mvcc_db_total_size_in_use_in_bytes",
              "ClusterName",
              module.eks.cluster_name
            ]
          ]

          period = 300
          stat   = "Maximum"
          view   = "timeSeries"
        }
      }
    ],

    # ------------------------------------------------------------
    # DYNAMIC INGRESS ALB WIDGETS
    # ------------------------------------------------------------

    flatten([
      for name, alb in data.aws_lb.ingress : [

        {
          type   = "metric"
          x      = 0
          y      = 32
          width  = 12
          height = 6

          properties = {
            title  = "Ingress ALB ${name} - ELB 5XX"
            region = "ap-south-1"

            metrics = [
              [
                "AWS/ApplicationELB",
                "HTTPCode_ELB_5XX_Count",
                "LoadBalancer",
                alb.arn_suffix
              ]
            ]

            period = 300
            stat   = "Sum"
            view   = "timeSeries"
          }
        },

        {
          type   = "metric"
          x      = 12
          y      = 32
          width  = 12
          height = 6

          properties = {
            title  = "Ingress ALB ${name} - Target Response Time"
            region = "ap-south-1"

            metrics = [
              [
                "AWS/ApplicationELB",
                "TargetResponseTime",
                "LoadBalancer",
                alb.arn_suffix
              ]
            ]

            period = 300
            stat   = "Average"
            view   = "timeSeries"
          }
        }
      ]
    ])
  )
}
############################################
# Fluent Bit
############################################

module "fluent_bit" {

  source = "../../modules/monitoring/fluent-bit"
  providers = {
    helm = helm
  }
  ##########################################
  # Project
  ##########################################

  project_name = var.project_name

  environment = var.environment

  common_tags = var.common_tags

  ##########################################
  # AWS
  ##########################################

  region = var.region

  ##########################################
  # EKS
  ##########################################

  cluster_name = module.eks.cluster_name

  irsa_role_arn = module.eks.irsa_role_arns[
    "fluent-bit"
  ]

  ##########################################
  # Kubernetes
  ##########################################

  namespace = "amazon-cloudwatch"

  service_account_name = "fluent-bit"

  ##########################################
  # CloudWatch
  ##########################################

  log_group_name = "/aws/containerinsights/${module.eks.cluster_name}/application"

  log_retention_days = 30

  ##########################################
  # Helm
  ##########################################

  helm_repository = var.fluent_bit_helm_repository

  chart_name = var.fluent_bit_chart_name

  chart_version = var.fluent_bit_chart_version

  depends_on = [
    module.eks
  ]

}
