output "container_image_url" {
  value = "${azurerm_container_registry.ContainerRegistry.login_server}/${local.image_names[0]}"
}
output "container_registry_server" {
  value = azurerm_container_registry.ContainerRegistry.login_server
}
output "container_registry_admin_username" {
  value = azurerm_container_registry.ContainerRegistry.admin_username
}
output "container_registry_admin_password" {
  value = azurerm_container_registry.ContainerRegistry.admin_password
}