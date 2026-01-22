locals {
  #LAW
  law_sku            = "PerGB2018"
  law_retention_days = 30
  law_name           = "${var.prefix}-law"
  #LOG STORAGE
  log_storage_account_name             = "${var.prefix}-log-storage-account"
  log_storage_account_tier             = "Standard"
  log_storage_account_replication_type = "LRS"
  log_storage_account_min_tls_version  = "TLS1_2"
}
