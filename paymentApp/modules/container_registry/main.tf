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
############################
# Private DNS Zone for acr #
############################
resource "azurerm_private_dns_zone" "paymentapp-acrzone" {
  name = "privatelink.azurecr.io"

  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "paymentapp-acrzonelink" {
  name                  = "paymentapp-acrzonelink"
  private_dns_zone_name = azurerm_private_dns_zone.paymentapp-acrzone.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
  tags                  = var.tags
}
############################
# Private endpoint for acr #
############################
resource "azurerm_private_endpoint" "res-0" {
  custom_network_interface_name = "paymentapp-aks-private-nic"
  location                      = var.location
  name                          = "paymentapp-aks-private"
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.aks_subnet_id
  tags                          = var.tags
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.paymentapp-acrzone.id]
  }
  private_service_connection {
    is_manual_connection           = false
    name                           = "paymentapp-aks-private"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
  }
}
