####################
### AKS cluster  ###
####################
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = local.k8s_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.prefix
  kubernetes_version  = local.k8s_cluster_version

  oidc_issuer_enabled       = local.k8s_cluster_oidc_issuer_enabled
  workload_identity_enabled = local.k8s_cluster_workload_identity_enabled
  
  identity {
    type = local.k8s_cluster_identity_type
  }

  default_node_pool {
    name                = local.k8s_cluster_default_node_pool_name
    node_count          = local.k8s_cluster_default_node_node_count
    vm_size             = local.k8s_cluster_default_node_vm_size
    auto_scaling_enabled = local.k8s_cluster_default_node_auto_scaling_enabled
    min_count           = local.k8s_cluster_default_node_min_count
    max_count           = local.k8s_cluster_default_node_max_count
    vnet_subnet_id      = var.aks_subnet_id
    only_critical_addons_enabled = local.k8s_cluster_default_node_only_critical_addons_enabled
  }

  network_profile {
    network_plugin    = local.k8s_cluster_default_network_profile_network_plugin
    network_policy    = local.k8s_cluster_default_network_profile_network_policy
    load_balancer_sku = local.k8s_cluster_default_network_profile_load_balancer_sku
    service_cidr      = local.k8s_cluster_default_network_profile_service_cidr
    dns_service_ip    = local.k8s_cluster_default_network_profile_dns_service_ip
  }

  oms_agent {
    log_analytics_workspace_id = var.law_id
  }

  ingress_application_gateway {
    gateway_name = local.k8s_cluster_default_ingress_application_gateway_name
    subnet_id    = var.app_gateway_subnet_id
  }
  
  key_vault_secrets_provider {
    secret_rotation_enabled = local.k8s_cluster_key_vault_secrets_provider_secret_rotation_enabled
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}