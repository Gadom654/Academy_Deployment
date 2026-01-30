output "admin_username" {
  value = azurerm_postgresql_flexible_server.payment_db.administrator_login
}

output "admin_password" {
  value     = azurerm_postgresql_flexible_server.payment_db.administrator_password
  sensitive = true
}