locals {
  container_registry_name          = "${var.prefix}acr"
  container_registry_sku_standard  = "Premium"
  container_registry_admin_enabled = false
}