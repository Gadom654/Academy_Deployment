locals {
  custom_rule_type                   = "cpu"
  metadata_type                      = "Utilization"
  metadata_value                     = "50"
  custom_scale_rule_name             = "cpu-scale-rule"
  allow_gw_manager_inbound_rule_name                                  = "${var.name}-allow-gw-manager-inbound-rule"
  allow_gw_manager_inbound_rule_priority                              = 101
  allow_gw_manager_inbound_rule_direction                             = "Inbound"
  allow_gw_manager_inbound_rule_access                                = "Allow"
  allow_gw_manager_inbound_rule_protocol                              = "Tcp"
  allow_gw_manager_inbound_rule_source_port_range                     = "*"
  allow_gw_manager_inbound_rule_destination_port_range                = "65200-65535"
  allow_gw_manager_inbound_rule_source_address_prefix                 = "GatewayManager"
  allow_gw_manager_inbound_rule_destination_address_prefix            = "*"
}