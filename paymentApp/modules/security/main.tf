####################
### Key Vault    ###
####################
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = local.kv_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = local.kv_sku_name

}
resource "azurerm_key_vault_access_policy" "planerAccessPolicy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_key_vault_access_policy" "applyAccessPolicy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = local.applyID

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"
  ]
}
################
# Azure Policy #
################
resource "azurerm_resource_group_policy_assignment" "allow-eu_only" {
  name                 = local.allow-eu_only_name
  location             = var.location
  resource_group_id    = var.resource_group_id
  policy_definition_id = local.allow-eu_only_policy_definition_id

  display_name = local.allow-eu_only_display_name
  description  = local.allow-eu_only_description
  parameters   = local.allow-eu_only_parameters
}