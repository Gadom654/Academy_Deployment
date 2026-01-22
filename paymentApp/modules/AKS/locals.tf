locals {
  k8s_cluster_name = "${var.prefix}-aks"
  k8s_cluster_version = "1.29"
  k8s_cluster_oidc_issuer_enabled = true
  k8s_cluster_workload_identity_enabled = true
  k8s_cluster_identity_type = "SystemAssigned"
  k8s_cluster_default_node_pool_name = "default"
  k8s_cluster_default_node_node_count = 1
  k8s_cluster_default_node_vm_size = "Standard_D2_v5"
  k8s_cluster_default_node_auto_scaling_enabled = true
  k8s_cluster_default_node_min_count = 1
  k8s_cluster_default_node_max_count = 4
  k8s_cluster_default_node_only_critical_addons_enabled = true
  k8s_cluster_default_network_profile_network_plugin = "azure"
  k8s_cluster_default_network_profile_network_policy = "azure"
  k8s_cluster_default_network_profile_load_balancer_sku = "standard"
  k8s_cluster_default_network_profile_service_cidr = "172.16.0.0/16"
  k8s_cluster_default_network_profile_dns_service_ip = "172.16.0.10"
  k8s_cluster_key_vault_secrets_provider_secret_rotation_enabled = true
  k8s_cluster_default_ingress_application_gateway_name = "default"
}