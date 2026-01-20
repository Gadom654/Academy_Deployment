locals {
  container_registry_name           = "${var.prefix}acr"
  container_registry_sku_standard   = "Basic"
  container_registry_admin_enabled  = false
  retention_policy_in_days = 7
  isTrustPolicyEnabled = true
}