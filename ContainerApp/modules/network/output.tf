output "private_subnet_1_id" {
  value = azurerm_subnet.PrivateSubnet1.id
}
output "private_subnet_2_id" {
  value = azurerm_subnet.PrivateSubnet2.id
}
output "public_subnet_1_id" {
  value = azurerm_subnet.PublicSubnet1.id
}
output "public_subnet_2_id" {
  value = azurerm_subnet.PublicSubnet2.id
}