##################################
### Log Analytics Workspace    ###
##################################
resource "azurerm_log_analytics_workspace" "PaymentInfraLAW" {
  name                = local.law_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = local.law_sku
  retention_in_days   = local.law_retention_days

  tags = var.tags

}

#################################
# Storage Account for Loki Logs #
#################################
resource "azurerm_storage_account" "log_storage_account" {
  name                     = local.log_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  tags                     = var.tags
  account_tier             = local.log_storage_account_tier
  account_replication_type = local.log_storage_account_replication_type
  min_tls_version          = local.log_storage_account_min_tls_version
}
