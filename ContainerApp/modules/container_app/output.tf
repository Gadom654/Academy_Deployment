output "app_1_url" {
  value = azurerm_container_app.PrivateContainerApp1.ingress[0].fqdn
}

output "app_2_url" {
  value = azurerm_container_app.PrivateContainerApp2.ingress[0].fqdn
}

output "app_1_domain" {
  value = replace(
    azurerm_container_app.PrivateContainerApp1.ingress[0].fqdn,
    "${azurerm_container_app.PrivateContainerApp1.name}.",
    ""
  )
}

output "app_2_domain" {
  value = replace(
    azurerm_container_app.PrivateContainerApp2.ingress[0].fqdn,
    "${azurerm_container_app.PrivateContainerApp2.name}.",
    ""
  )
}

output "container_app_env_1_ip" {
  value = azurerm_container_app_environment.PrivateContainerAppEnv1.static_ip_address
}

output "container_app_env_2_ip" {
  value = azurerm_container_app_environment.PrivateContainerAppEnv2.static_ip_address
}