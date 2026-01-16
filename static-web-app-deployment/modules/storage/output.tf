# Primary web host URL of the storage account
output "primary_web_host" {
  value = azurerm_storage_account.mainstorage.primary_web_host
}

# ID of the storage account
output "main_storage_account_id" {
  value = azurerm_storage_account.mainstorage.id
}

output "error_web_host" {
  value = azurerm_storage_account.errorstorage.primary_web_host
}

output "error_storage_account_id" {
  value = azurerm_storage_account.errorstorage.id
}