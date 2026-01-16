locals {
  law_sku              = "PerGB2018"
  law_retention_days   = 30
  law_name             = "${var.prefix}-law"
  afd_diagnostics_name = "${var.prefix}-afd-diagnostics"
  fdac                 = "FrontDoorAccessLog"
  fdwaf                = "FrontDoorWebApplicationFirewallLog"
  metrics_scope        = "AllMetrics"
  dashboard_name       = "${var.prefix}-afd-monitoring-dashboard"
}