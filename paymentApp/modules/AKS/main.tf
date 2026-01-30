####################
### AKS cluster  ###
####################
data "azurerm_user_assigned_identity" "aks_identity" {
  name                = "karpenter-uai"
  resource_group_name = "uai-group"
}
resource "azurerm_kubernetes_cluster" "k8s" {
  name                      = local.k8s_cluster_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = var.prefix
  kubernetes_version        = local.k8s_cluster_version
  tags                      = var.tags
  oidc_issuer_enabled       = local.k8s_cluster_oidc_issuer_enabled
  workload_identity_enabled = local.k8s_cluster_workload_identity_enabled
  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.aks_identity.id]
  }
  node_provisioning_profile {
    mode               = "Auto"
    default_node_pools = "None"
  }
  default_node_pool {
    name                         = local.k8s_cluster_default_node_pool_name
    node_count                   = local.k8s_cluster_default_node_node_count
    vm_size                      = local.k8s_cluster_default_node_vm_size
    auto_scaling_enabled         = local.k8s_cluster_default_node_auto_scaling_enabled
    vnet_subnet_id               = var.aks_subnet_id
    only_critical_addons_enabled = local.k8s_cluster_default_node_only_critical_addons_enabled
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  network_profile {
    network_plugin    = local.k8s_cluster_default_network_profile_network_plugin
    network_policy    = local.k8s_cluster_default_network_profile_network_policy
    load_balancer_sku = local.k8s_cluster_default_network_profile_load_balancer_sku
    service_cidr      = local.k8s_cluster_default_network_profile_service_cidr
    dns_service_ip    = local.k8s_cluster_default_network_profile_dns_service_ip
  }

  workload_autoscaler_profile {
    keda_enabled = local.k8s_cluster_workload_autoscaler_profile_keda_enabled
  }

  oms_agent {
    log_analytics_workspace_id = var.law_id
  }

  ingress_application_gateway {
    gateway_id = var.gateway_id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = local.k8s_cluster_key_vault_secrets_provider_secret_rotation_enabled
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
  monitor_metrics {
    annotations_allowed = null
    labels_allowed      = null
  }
}

########
# Flux #
########
resource "azurerm_kubernetes_cluster_extension" "flux" {
  name           = local.flux_name
  cluster_id     = azurerm_kubernetes_cluster.k8s.id
  extension_type = local.flux_extension_type
}
resource "azurerm_kubernetes_flux_configuration" "payment_app" {
  name       = "payment-app-config"
  cluster_id = azurerm_kubernetes_cluster.k8s.id
  namespace  = "flux-system"
  scope      = "cluster"
  depends_on = [azurerm_kubernetes_flux_configuration.karpenter]
  git_repository {
    url             = local.github_repo_url
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "main"

    path = "./paymentApp/flux/"

    sync_interval_in_seconds  = 300
    retry_interval_in_seconds = 300
  }
}

resource "azurerm_kubernetes_flux_configuration" "karpenter" {
  name       = "karpenter-config"
  cluster_id = azurerm_kubernetes_cluster.k8s.id
  namespace  = "flux-system"
  scope      = "cluster"
  depends_on = [azurerm_kubernetes_cluster_extension.flux]
  git_repository {
    url             = local.github_repo_url
    reference_type  = "branch"
    reference_value = "main"
  }

  kustomizations {
    name = "main"

    path = "./paymentApp/fluxkarpenter/"

    sync_interval_in_seconds  = 300
    retry_interval_in_seconds = 300
  }
}
###################
# Identity assign #
###################
resource "azurerm_federated_identity_credential" "karpenter" {
  name                = local.karpenter_federated_identity_credential_name
  resource_group_name = local.uai_group_name
  parent_id           = data.azurerm_user_assigned_identity.aks_identity.id
  audience            = local.karpenter_federated_identity_credential_audience
  issuer              = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
  subject             = local.karpenter_federated_identity_credential_subject
}
resource "azurerm_federated_identity_credential" "app" {
  name                = local.app_federated_identity_credential_name
  resource_group_name = local.uai_group_name
  parent_id           = data.azurerm_user_assigned_identity.aks_identity.id
  audience            = local.karpenter_federated_identity_credential_audience
  issuer              = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
  subject             = local.app_federated_identity_credential_subject
}