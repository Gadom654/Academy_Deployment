output "private_subnet_1_id" {
  value = azurerm_subnet.AKSSubnet.id
}
output "private_subnet_2_id" {
  value = azurerm_subnet.DBSubnet.id
}
output "public_subnet_1_id" {
  value = azurerm_subnet.AppGatewaySubnet.id
}
output "public_subnet_2_id" {
  value = azurerm_subnet.BastionSubnet.id
}
output "vnet_id" {
  value = azurerm_virtual_network.PaymentAppVNet.id
}