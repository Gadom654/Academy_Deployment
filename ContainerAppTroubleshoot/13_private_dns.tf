##################################
###      Private DNS Zones     ###
##################################
resource "azurerm_private_dns_zone" "PrivateDNSZone" {
  name                = replace(azurerm_container_app.web.ingress[0].fqdn,"${azurerm_container_app.web.name}.","")
  resource_group_name = azurerm_resource_group.rg.name
}
##################################
###   Private DNS Zone Links   ###
##################################
resource "azurerm_private_dns_zone_virtual_network_link" "DNSZoneVNetLink" {
  name                  = "dnszone1vnetlink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.PrivateDNSZone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}
################################
###       DNS Records        ###
################################
resource "azurerm_private_dns_a_record" "AppARecord" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.PrivateDNSZone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_container_app_environment.env.static_ip_address]
}