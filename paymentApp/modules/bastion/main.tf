#######################
###     Bastion     ###
#######################
resource "azurerm_public_ip" "bastion_ip" {
  name                = local.bastion_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "main" {
  name                = local.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku = local.bastion_sku

  ip_configuration {
    name                 = local.bastion_ip_config_name
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }
}