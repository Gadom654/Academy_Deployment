locals {
  #K8s
  k8s_cluster_name                                               = "${var.prefix}-aks"
  k8s_cluster_version                                            = "1.29"
  k8s_cluster_oidc_issuer_enabled                                = true
  k8s_cluster_workload_identity_enabled                          = true
  k8s_cluster_identity_type                                      = "SystemAssigned"
  k8s_cluster_default_node_pool_name                             = "default"
  k8s_cluster_default_node_node_count                            = 1
  k8s_cluster_default_node_vm_size                               = "Standard_D2_v5"
  k8s_cluster_default_node_auto_scaling_enabled                  = true
  k8s_cluster_default_node_min_count                             = 1
  k8s_cluster_default_node_max_count                             = 4
  k8s_cluster_default_node_only_critical_addons_enabled          = true
  k8s_cluster_default_network_profile_network_plugin             = "azure"
  k8s_cluster_default_network_profile_network_policy             = "azure"
  k8s_cluster_default_network_profile_load_balancer_sku          = "standard"
  k8s_cluster_default_network_profile_service_cidr               = "172.16.0.0/16"
  k8s_cluster_default_network_profile_dns_service_ip             = "172.16.0.10"
  k8s_cluster_workload_autoscaler_profile_keda_enabled           = true
  k8s_cluster_key_vault_secrets_provider_secret_rotation_enabled = true
  #Flux
  flux_name           = "${var.prefix}-flux"
  flux_extension_type = "microsoft.flux"
  #Karpenter
  karpenter_uai_name                               = "${var.prefix}-karpenter-uai"
  karpenter_network_role_definition_name           = "Network Contributor"
  karpenter_vm_operator_role_definition_name       = "Managed Identity Operator"
  karpenter_vm_contributor_role_definition_name    = "Virtual Machine Contributor"
  karpenter_federated_identity_credential_name     = "${var.prefix}-karpenter-fic"
  karpenter_federated_identity_credential_audience = ["api://AzureADTokenExchange"]
  karpenter_federated_identity_credential_subject  = "system:serviceaccount:karpenter:karpenter"
}