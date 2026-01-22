output "law_id" {
  value = azurerm_log_analytics_workspace.PaymentInfraLAW.id
}

output "loki_log_storage_id" {
  value = azurerm_storage_account.log_storage_account.id
}