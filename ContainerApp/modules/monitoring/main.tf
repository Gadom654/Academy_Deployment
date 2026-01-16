##################################
### Log Analytics Workspace    ###
##################################
resource "azurerm_log_analytics_workspace" "ContainerLAW" {
  name                = local.law_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = local.law_sku
  retention_in_days   = local.law_retention_days

  tags = var.tags

}