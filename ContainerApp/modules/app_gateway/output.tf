output "app_gateway_1_public_ip" {
  value = azurerm_public_ip.AppGateway1PIP.ip_address
}

output "app_gateway_2_public_ip" {
  value = azurerm_public_ip.AppGateway2PIP.ip_address
}