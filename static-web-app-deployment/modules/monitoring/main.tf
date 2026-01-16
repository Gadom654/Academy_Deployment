# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "monitoring" {
  name                = local.law_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = local.law_sku
  retention_in_days   = local.law_retention_days

  tags = var.tags

}

# Create Diagnostic Setting for AFD Profile
resource "azurerm_monitor_diagnostic_setting" "afd_diagnostics" {
  name                       = local.afd_diagnostics_name
  target_resource_id         = var.afd_profile_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitoring.id

  # Access Logs (for Request rates and 4xx/5xx)
  enabled_log {
    category = local.fdac
  }

  # Web Application Firewall Logs (for blocked requests)
  enabled_log {
    category = local.fdwaf
  }

  enabled_metric {
    category = local.metrics_scope
  }

}

resource "azurerm_portal_dashboard" "adf_dashboard" {
  name                = local.dashboard_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
  location            = var.location

  dashboard_properties = templatefile("./modules/monitoring/dashboard.json", {
    front_door_id = var.afd_profile_id
    location      = var.location
  })

}

