##################################
###       Virtual Network      ###
################################## 
resource "azurerm_virtual_network" "PaymentAppVNet" {
  name                = local.vnet_name
  address_space       = local.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

##################################
###          Subnets           ###
##################################
resource "azurerm_subnet" "AKSSubnet" {
  name                            = local.private_subnet_1_name
  resource_group_name             = var.resource_group_name
  virtual_network_name            = azurerm_virtual_network.PaymentAppVNet.name
  address_prefixes                = local.private_subnet_1_address_space
  default_outbound_access_enabled = local.private_subnets_outbound_access_enabled
}
resource "azurerm_subnet" "DBSubnet" {
  name                            = local.private_subnet_2_name
  resource_group_name             = var.resource_group_name
  virtual_network_name            = azurerm_virtual_network.PaymentAppVNet.name
  address_prefixes                = local.private_subnet_2_address_space
  default_outbound_access_enabled = local.private_subnets_outbound_access_enabled
  delegation {
    name = local.private_subnet_2_delegation_name
    service_delegation {
      name    = local.private_subnet_2_service_delegation
      actions = [local.private_subnet_2_delegated_actions]
    }
  }
}
resource "azurerm_subnet" "AppGatewaySubnet" {
  name                 = local.public_subnet_1_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.PaymentAppVNet.name
  address_prefixes     = local.public_subnet_1_address_space
}
resource "azurerm_subnet" "BastionSubnet" {
  name                 = local.public_subnet_2_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.PaymentAppVNet.name
  address_prefixes     = local.public_subnet_2_address_space
}
resource "azurerm_subnet" "DBSubnet2" {
  name                            = local.private_subnet_3_name
  resource_group_name             = var.resource_group_name
  virtual_network_name            = azurerm_virtual_network.PaymentAppVNet.name
  address_prefixes                = local.private_subnet_3_address_space
  default_outbound_access_enabled = local.private_subnets_outbound_access_enabled
}

##################################
###         NAT Gateway        ###
##################################
resource "azurerm_public_ip" "PrivateSubnetsNATPublicIP" {
  name                = local.nat_gateway_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = local.nat_gateway_ip_allocation_method
  sku                 = local.nat_gateway_sku_standard
  tags                = var.tags

}
resource "azurerm_nat_gateway" "PrivateSubnetsNATGateway" {
  name                = local.nat_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
resource "azurerm_nat_gateway_public_ip_association" "NATGatewayPublicIPAssociation" {
  nat_gateway_id       = azurerm_nat_gateway.PrivateSubnetsNATGateway.id
  public_ip_address_id = azurerm_public_ip.PrivateSubnetsNATPublicIP.id
}
resource "azurerm_subnet_nat_gateway_association" "AKSNATAssociation" {
  subnet_id      = azurerm_subnet.AKSSubnet.id
  nat_gateway_id = azurerm_nat_gateway.PrivateSubnetsNATGateway.id
}
resource "azurerm_subnet_nat_gateway_association" "DBNATAssociation" {
  subnet_id      = azurerm_subnet.DBSubnet2.id
  nat_gateway_id = azurerm_nat_gateway.PrivateSubnetsNATGateway.id
}
##################################
###  Security Groups & Rules   ###
##################################
resource "azurerm_network_security_group" "nsg-app-gateway" {
  name                = local.nsg-app-gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = local.nsg-app-gateway_rule_1_name
    priority                   = local.nsg-app-gateway_rule_1_priority
    direction                  = local.nsg-app-gateway_rule_1_direction
    access                     = local.nsg-app-gateway_rule_1_access
    protocol                   = local.nsg-app-gateway_rule_1_protocol
    source_port_range          = local.nsg-app-gateway_rule_1_source_port_range
    destination_port_ranges    = local.nsg-app-gateway_rule_1_destination_port_range
    source_address_prefix      = local.nsg-app-gateway_rule_1_source_address_prefix
    destination_address_prefix = local.nsg-app-gateway_rule_1_destination_address_prefix
  }

  # Required by Azure for App Gateway Health Probes
  security_rule {
    name                       = local.nsg-app-gateway_rule_2_name
    priority                   = local.nsg-app-gateway_rule_2_priority
    direction                  = local.nsg-app-gateway_rule_2_direction
    access                     = local.nsg-app-gateway_rule_2_access
    protocol                   = local.nsg-app-gateway_rule_2_protocol
    source_port_range          = local.nsg-app-gateway_rule_2_source_port_range
    destination_port_range     = local.nsg-app-gateway_rule_2_destination_port_range
    source_address_prefix      = local.nsg-app-gateway_rule_2_source_address_prefix
    destination_address_prefix = local.nsg-app-gateway_rule_2_destination_address_prefix
  }
}

resource "azurerm_subnet_network_security_group_association" "app_gw_assoc" {
  subnet_id                 = azurerm_subnet.AppGatewaySubnet.id
  network_security_group_id = azurerm_network_security_group.nsg-app-gateway.id
}

resource "azurerm_network_security_group" "aks_nsg" {
  name                = local.nsg-aks-name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = local.nsg-aks-rule-1_name
    priority                   = local.nsg-aks-rule-1_priority
    direction                  = local.nsg-aks-rule-1_direction
    access                     = local.nsg-aks-rule-1_access
    protocol                   = local.nsg-aks-rule-1_protocol
    source_port_range          = local.nsg-aks-rule-1_source_port_range
    destination_port_ranges    = local.nsg-aks-rule-1_destination_port_range
    source_address_prefix      = local.nsg-aks-rule-1_source_address_prefix
    destination_address_prefix = local.nsg-aks-rule-1_destination_address_prefix
  }
}

resource "azurerm_subnet_network_security_group_association" "aks_assoc" {
  subnet_id                 = azurerm_subnet.AKSSubnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

resource "azurerm_network_security_group" "db_nsg" {
  name                = local.nsg-db-name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = local.nsg-db-name-rule-1_name
    priority                   = local.nsg-db-name-rule-1_priority
    direction                  = local.nsg-db-name-rule-1_direction
    access                     = local.nsg-db-name-rule-1_access
    protocol                   = local.nsg-db-name-rule-1_protocol
    source_port_range          = local.nsg-db-name-rule-1_source_port_range
    destination_port_ranges    = local.nsg-db-name-rule-1_destination_port_range
    source_address_prefix      = local.nsg-db-name-rule-1_source_address_prefix
    destination_address_prefix = local.nsg-db-name-rule-1_destination_address_prefix
  }
  security_rule {
    name                       = local.nsg-db-name-rule-2_name
    priority                   = local.nsg-db-name-rule-2_priority
    direction                  = local.nsg-db-name-rule-2_direction
    access                     = local.nsg-db-name-rule-2_access
    protocol                   = local.nsg-db-name-rule-2_protocol
    source_port_range          = local.nsg-db-name-rule-2_source_port_range
    destination_port_ranges    = local.nsg-db-name-rule-2_destination_port_range
    source_address_prefix      = local.nsg-db-name-rule-2_source_address_prefix
    destination_address_prefix = local.nsg-db-name-rule-2_destination_address_prefix
  }
}

resource "azurerm_subnet_network_security_group_association" "db_assoc" {
  subnet_id                 = azurerm_subnet.DBSubnet.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

resource "azurerm_network_security_group" "bastion_nsg" {
  name                = local.nsg-bastion-name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = local.nsg-bastion-name-rule-1_name
    priority                   = local.nsg-bastion-name-rule-1_priority
    direction                  = local.nsg-bastion-name-rule-1_direction
    access                     = local.nsg-bastion-name-rule-1_access
    protocol                   = local.nsg-bastion-name-rule-1_protocol
    source_port_range          = local.nsg-bastion-name-rule-1_source_port_range
    destination_port_ranges    = local.nsg-bastion-name-rule-1_destination_port_range
    source_address_prefix      = local.nsg-bastion-name-rule-1_source_address_prefix
    destination_address_prefix = local.nsg-bastion-name-rule-1_destination_address_prefix
  }

  security_rule {
    name                       = local.nsg-bastion-name-rule-2_name
    priority                   = local.nsg-bastion-name-rule-2_priority
    direction                  = local.nsg-bastion-name-rule-2_direction
    access                     = local.nsg-bastion-name-rule-2_access
    protocol                   = local.nsg-bastion-name-rule-2_protocol
    source_port_range          = local.nsg-bastion-name-rule-2_source_port_range
    destination_port_range     = local.nsg-bastion-name-rule-2_destination_port_range
    source_address_prefix      = local.nsg-bastion-name-rule-2_source_address_prefix
    destination_address_prefix = local.nsg-bastion-name-rule-2_destination_address_prefix
  }

  security_rule {
    name                       = local.nsg-bastion-name-rule-3_name
    priority                   = local.nsg-bastion-name-rule-3_priority
    direction                  = local.nsg-bastion-name-rule-3_direction
    access                     = local.nsg-bastion-name-rule-3_access
    protocol                   = local.nsg-bastion-name-rule-3_protocol
    source_port_range          = local.nsg-bastion-name-rule-3_source_port_range
    destination_port_ranges    = local.nsg-bastion-name-rule-3_destination_port_range
    source_address_prefix      = local.nsg-bastion-name-rule-3_source_address_prefix
    destination_address_prefix = local.nsg-bastion-name-rule-3_destination_address_prefix
  }

  security_rule {
    name                       = local.nsg-bastion-name-rule-4_name
    priority                   = local.nsg-bastion-name-rule-4_priority
    direction                  = local.nsg-bastion-name-rule-4_direction
    access                     = local.nsg-bastion-name-rule-4_access
    protocol                   = local.nsg-bastion-name-rule-4_protocol
    source_port_range          = local.nsg-bastion-name-rule-4_source_port_range
    destination_port_range     = local.nsg-bastion-name-rule-4_destination_port_range
    source_address_prefix      = local.nsg-bastion-name-rule-4_source_address_prefix
    destination_address_prefix = local.nsg-bastion-name-rule-4_destination_address_prefix
  }
}

resource "azurerm_subnet_network_security_group_association" "bastion_assoc" {
  subnet_id                 = azurerm_subnet.BastionSubnet.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}
resource "azurerm_network_security_group" "db_nsg2" {
  name                = local.nsg-db-name2
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = local.nsg-db-name2-rule-1_name
    priority                   = local.nsg-db-name2-rule-1_priority
    direction                  = local.nsg-db-name2-rule-1_direction
    access                     = local.nsg-db-name2-rule-1_access
    protocol                   = local.nsg-db-name2-rule-1_protocol
    source_port_range          = local.nsg-db-name2-rule-1_source_port_range
    destination_port_ranges    = local.nsg-db-name2-rule-1_destination_port_range
    source_address_prefix      = local.nsg-db-name2-rule-1_source_address_prefix
    destination_address_prefix = local.nsg-db-name2-rule-1_destination_address_prefix
  }
  security_rule {
    name                       = local.nsg-db-name2-rule-2_name
    priority                   = local.nsg-db-name2-rule-2_priority
    direction                  = local.nsg-db-name2-rule-2_direction
    access                     = local.nsg-db-name2-rule-2_access
    protocol                   = local.nsg-db-name2-rule-2_protocol
    source_port_range          = local.nsg-db-name2-rule-2_source_port_range
    destination_port_ranges    = local.nsg-db-name2-rule-2_destination_port_range
    source_address_prefix      = local.nsg-db-name2-rule-2_source_address_prefix
    destination_address_prefix = local.nsg-db-name2-rule-2_destination_address_prefix
  }
}

resource "azurerm_subnet_network_security_group_association" "db_assoc2" {
  subnet_id                 = azurerm_subnet.DBSubnet2.id
  network_security_group_id = azurerm_network_security_group.db_nsg2.id
}