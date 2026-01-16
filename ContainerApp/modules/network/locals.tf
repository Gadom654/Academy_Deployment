locals {
  vnet_name                                                           = "${var.prefix}-vnet"
  vnet_address_space                                                  = ["10.0.0.0/16"]
  private_subnet_1_name                                               = "${var.prefix}-private-subnet-1"
  private_subnet_1_address_space                                      = ["10.0.0.0/24"]
  private_subnet_2_name                                               = "${var.prefix}-private-subnet-2"
  private_subnet_2_address_space                                      = ["10.0.1.0/24"]
  public_subnet_1_name                                                = "${var.prefix}-public-subnet-1"
  public_subnet_1_address_space                                       = ["10.0.2.0/24"]
  public_subnet_2_name                                                = "${var.prefix}-public-subnet-2"
  public_subnet_2_address_space                                       = ["10.0.3.0/24"]
  private_subnets_outbound_access_enabled                             = false
  nat_gateway_name                                                    = "${var.prefix}-nat-gateway"
  nat_gateway_ip_name                                                 = "${var.prefix}-nat-gateway-pip"
  nat_gateway_ip_allocation_method                                    = "Static"
  nat_gateway_sku_standard                                            = "Standard"
  dns_vnet_link_name1                                                 = "${var.prefix}-dns-vnet-link1"
  dns_vnet_link_name2                                                 = "${var.prefix}-dns-vnet-link2"
  isregistration_enabled                                              = false
  a_dns_record_name                                                   = "*"
  ttl_value                                                           = 300
  service_delegation                                                  = "Microsoft.App/environments"
  delegated_actions                                                   = "Microsoft.Network/virtualNetworks/subnets/join/action"
  private_subnet_1_delegation_name                                    = "${var.prefix}-private-subnet-1-delegation"
  private_subnet_2_delegation_name                                    = "${var.prefix}-private-subnet-2-delegation"
  security_group_name                                                 = "${var.prefix}-nsg"
  allow_app_gateway_to_container_apps_rule_name                       = "${var.prefix}-allow-public-to-private-rule"
  allow_app_gateway_to_container_apps_rule_priority                   = 100
  allow_app_gateway_to_container_apps_rule_direction                  = "Inbound"
  allow_app_gateway_to_container_apps_rule_access                     = "Allow"
  allow_app_gateway_to_container_apps_rule_protocol                   = "Tcp"
  allow_app_gateway_to_container_apps_rule_source_port_range          = "*"
  allow_app_gateway_to_container_apps_rule_destination_port_range     = "80"
  allow_gw_manager_inbound_rule_name                                  = "${var.prefix}-allow-gw-manager-inbound-rule"
  allow_gw_manager_inbound_rule_priority                              = 101
  allow_gw_manager_inbound_rule_direction                             = "Inbound"
  allow_gw_manager_inbound_rule_access                                = "Allow"
  allow_gw_manager_inbound_rule_protocol                              = "Tcp"
  allow_gw_manager_inbound_rule_source_port_range                     = "*"
  allow_gw_manager_inbound_rule_destination_port_range                = "65200-65535"
  allow_gw_manager_inbound_rule_source_address_prefix                 = "GatewayManager"
  allow_gw_manager_inbound_rule_destination_address_prefix            = "*"
  allow_http_from_internet_to_app_gateway_rule_name                   = "${var.prefix}-allow-http-from-internet-to-app-gateway-rule"
  allow_http_from_internet_to_app_gateway_rule_priority               = 102
  allow_http_from_internet_to_app_gateway_rule_direction              = "Inbound"
  allow_http_from_internet_to_app_gateway_rule_access                 = "Allow"
  allow_http_from_internet_to_app_gateway_rule_protocol               = "Tcp"
  allow_http_from_internet_to_app_gateway_rule_source_port_range      = "*"
  allow_http_from_internet_to_app_gateway_rule_destination_port_range = "80"
  allow_http_from_internet_to_app_gateway_rule_source_address_prefix  = "*"
  allow_http_from_internet_to_app_gateway_rule_destination_address_prefixes = [
    "${var.app_gateway_1_public_ip}",
    "${var.app_gateway_2_public_ip}"
  ]
}
