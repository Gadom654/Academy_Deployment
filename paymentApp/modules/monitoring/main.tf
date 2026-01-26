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
##############
# Prometheus #
##############
resource "azurerm_monitor_workspace" "prometheus" {
  name                = local.prometheus_monitor_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Link AKS to the Prometheus Workspace
resource "azurerm_monitor_data_collection_rule_association" "aks_prometheus" {
  name                    = local.aks_prometheus_link_name
  target_resource_id      = var.k8s_cluster_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.prometheus.id
}

resource "azurerm_monitor_data_collection_rule" "prometheus" {
  name                = local.data_collection_rule_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  kind                = local.data_collection_rule_kind

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.prometheus.id
      name               = local.data_collection_rule_monitor_account_name
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["monitoringAccount1"]
  }

  data_sources {
    prometheus_forwarder {
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "PrometheusDataSource"
    }
  }
}
###########
# Grafana #
###########
resource "azurerm_dashboard_grafana" "grafana" {
  name                              = local.grafana_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true
  grafana_major_version             = "11"
  tags                              = var.tags

  identity {
    type = "SystemAssigned"
  }
}

