#################################
### Database Private DNS Zone ###
#################################
resource "azurerm_private_dns_zone" "postgres_dns_zone" {
  name                = local.postgres_dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link the DNS Zone to the VNet so AKS can resolve the DB address
resource "azurerm_private_dns_zone_virtual_network_link" "postgres_dns_zone_link" {
  name                  = local.postgres_dns_zone_link_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns_zone.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
  tags                  = var.tags
}
#########################
### Database Password ###
#########################
resource "random_password" "db_pass" {
  length           = local.db_pass_length
  special          = local.db_pass_special
  override_special = local.db_pass_override_special
}
resource "azurerm_key_vault_secret" "db_password" {
  name         = local.db_password_name
  value        = random_password.db_pass.result
  key_vault_id = var.key_vault_id
}
################
### Database ###
################
resource "azurerm_postgresql_flexible_server" "payment_db" {
  name                = local.payment_db_server_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  version             = local.payment_db_version

  public_network_access_enabled = false

  zone = local.payment_db_zone

  # Network injection
  delegated_subnet_id = var.subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.postgres_dns_zone.id

  administrator_login    = var.admin_username
  administrator_password = random_password.db_pass.result

  storage_mb = local.payment_db_storage_mb
  sku_name   = local.payment_db_sku_name

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres_dns_zone_link]
}

resource "azurerm_postgresql_flexible_server_database" "app_db" {
  name      = local.app_db_name
  server_id = azurerm_postgresql_flexible_server.payment_db.id
  charset   = local.app_db_charset
  collation = local.app_db_collation
}
#################
# Database logs #
#################
resource "azurerm_monitor_diagnostic_setting" "db_diag" {
  name                       = local.db_diag_name
  target_resource_id         = azurerm_postgresql_flexible_server.payment_db.id
  log_analytics_workspace_id = var.law_id

  enabled_log {
    category_group = local.db_diag_category_group
  }

  metric {
    category = local.db_diag_metric_category
    enabled  = local.db_diag_metric_enabled
  }
}