locals {
  #LAW
  law_sku            = "PerGB2018"
  law_retention_days = 30
  law_name           = "${var.prefix}law"
  #LOG STORAGE
  log_storage_account_name             = "${var.prefix}lsa"
  log_storage_account_tier             = "Standard"
  log_storage_account_replication_type = "LRS"
  log_storage_account_min_tls_version  = "TLS1_2"
  #PROMETHEUS
  prometheus_monitor_name = "${var.prefix}prometheus"
  aks_prometheus_link_name = "${var.prefix}aks-prometheus-link"
  data_collection_rule_name = "${var.prefix}data-collection-rule"
  data_collection_rule_kind = "Linux"
  data_collection_rule_monitor_account_name = "monitoringAccount1"
  #GRAFANA
  grafana_name = "${var.prefix}grafana"
}
