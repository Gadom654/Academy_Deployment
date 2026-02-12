locals {
  addons = [
    # https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html#vpc-cni-latest-available-version
    {
      addon_name                  = "vpc-cni"
      addon_version               = var.vpc_cni_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = var.vpc_cni_service_account_role_arn
    },
    # https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
    {
      addon_name                  = "kube-proxy"
      addon_version               = var.kube_proxy_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
    },
    # https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
    {
      addon_name                  = "coredns"
      addon_version               = var.coredns_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
    },
    {
      addon_name                  = "aws-secrets-store-csi-driver-provider"
      addon_version               = var.secret_store_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
      configuration_values = jsonencode({
        "secrets-store-csi-driver" = {
          syncSecret = {
            enabled = true
          }
          enableSecretRotation = true
          rotationPollInterval = "3600s"
        }
      })
    },
    {
      addon_name                  = "metrics-server"
      addon_version               = var.metrics-server_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
    },
    {
      addon_name                  = "eks-pod-identity-agent"
      addon_version               = var.eks-pod-identity-agent_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
    },
    {
      addon_name                  = "amazon-cloudwatch-observability"
      addon_version               = var.cloudwatch_observability_version
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = null
      configuration_values = jsonencode({
        containerLogs = {
          enabled = true
          fluentBit = {
            resources = {
              limits = {
                cpu    = "500m"
                memory = "250Mi"
              }
              requests = {
                cpu    = "50m"
                memory = "25Mi"
              }
            }
          }
        }

        agents = [
          {
            name = "cloudwatch-agent"
            resources = {
              limits = {
                cpu    = "500m"
                memory = "512Mi"
              }
              requests = {
                cpu    = "250m"
                memory = "128Mi"
              }
            }
          }
        ]

        manager = {
          applicationSignals = {
            autoMonitor = {
              monitorAllServices = false
            }
          }
        }
      })
    },
  ]
}