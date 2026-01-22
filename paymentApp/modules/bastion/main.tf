##################################
###     Container Registry     ###
################################## 
resource "azurerm_container_registry" "acr" {
  name                = local.container_registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = local.container_registry_sku_standard
  admin_enabled       = local.container_registry_admin_enabled
  tags                = var.tags
}