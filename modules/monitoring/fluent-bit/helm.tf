############################################
# Fluent Bit Helm Release
############################################

resource "helm_release" "this" {

  name = "fluent-bit"

  namespace = var.namespace

  repository = var.helm_repository

  chart = var.chart_name

  version = var.chart_version

  create_namespace = true

  wait = true

  timeout = 600

  values = [
    yamlencode({

      ########################################
      # Service Account
      ########################################

      serviceAccount = {

        create = true

        name = var.service_account_name

        annotations = {

          "eks.amazonaws.com/role-arn" = var.irsa_role_arn

        }

      }

      ########################################
      # AWS Region
      ########################################

      awsRegion = var.region

      ########################################
      # CloudWatch Logs
      ########################################

      cloudWatchLogs = {

        enabled = true

        region = var.region

        logGroupName = var.log_group_name

        logStreamPrefix = "fluent-bit-"

        autoCreateGroup = false

      }

      ########################################
      # Kubernetes Filter
      ########################################

      filter = {

        kubeURL = "https://kubernetes.default.svc:443"

        kubeTagPrefix = "kube.var.log.containers."

        mergeLog = true

        mergeLogKey = "log_processed"

        keepLog = false

        labels = false

        annotations = false

        useKubelet = true

        kubeletPort = 10250

        bufferSize = "0"

      }

      ########################################
      # Log Input
      ########################################

      input = {

        tag = "kube.*"

        path = "/var/log/containers/*.log"

        db = "/var/log/flb_kube.db"

        multilineParser = "docker, cri"

        memBufLimit = "5MB"

        skipLongLines = "On"

        refreshInterval = "10"

      }

      ########################################
      # Fluent Bit Service
      ########################################

      service = {

        flush = 5

        logLevel = "info"

        httpServer = "On"

        httpPort = 2020

      }

      ########################################
      # Resources
      ########################################

      resources = {

        requests = {

          cpu = "50m"

          memory = "100Mi"

        }

        limits = {

          cpu = "200m"

          memory = "300Mi"

        }

      }

      ########################################
      # Run on all nodes
      ########################################

      tolerations = [

        {

          operator = "Exists"

        }

      ]

    })
  ]

}
