##################################
###    Application gateways    ###
##################################
resource "azurerm_public_ip" "AppGateway1PIP" {
  name                = local.AppGateway1PIPName
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = local.IP_allocation_method
  tags                = var.tags
}
resource "azurerm_application_gateway" "AppGateway1" {
  name                = local.AppGateway1Name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = local.AppGatewaySKUName
    tier     = local.AppGatewaySKUTier
    capacity = local.AppGatewaySKUCapacity
  }

  gateway_ip_configuration {
    name      = local.gateway1_ip_configuration_name
    subnet_id = var.public_subnet_1_id
  }

  frontend_port {
    name = local.frontendPortName1
    port = local.frontendPort
  }

  frontend_ip_configuration {
    name                 = local.frontendIPConfigName1
    public_ip_address_id = azurerm_public_ip.AppGateway1PIP.id
  }

  backend_address_pool {
    name  = local.backendAddressPoolName1
    fqdns = [var.app_1_url]
  }

  backend_http_settings {
    name                                = local.backendHttpSettingsName1
    cookie_based_affinity               = local.is_cookie_based_affinity_enabled
    port                                = local.backendHttpSettingsPort
    protocol                            = local.backendHttpSettingsProtocol
    request_timeout                     = local.backendHttpSettingsRequestTimeout
    path                                = local.backendHttpSettingsPath
    probe_name                          = local.probeName1
    pick_host_name_from_backend_address = local.pickhostnamefrombackendhttpsettings
  }

  http_listener {
    name                           = local.httpListenerName1
    frontend_ip_configuration_name = local.frontendIPConfigName1
    frontend_port_name             = local.frontendPortName1
    protocol                       = local.httpListenerProtocol
  }

  request_routing_rule {
    name                       = local.routingRuleName1
    backend_address_pool_name  = local.backendAddressPoolName1
    backend_http_settings_name = local.backendHttpSettingsName1
    rule_type                  = local.routingRuleType
    priority                   = local.routingRulePriority
    http_listener_name         = local.httpListenerName1
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id
  
  probe {
    pick_host_name_from_backend_http_settings = local.pickhostnamefrombackendhttpsettings
    name                                      = local.probeName1
    protocol                                  = local.probeProtocol
    path                                      = local.probePath
    interval                                  = local.probeInterval
    timeout                                   = local.probeTimeout
    unhealthy_threshold                       = local.probeUnhealthyThreshold
    port                                      = local.probePort
    match {
      status_code = local.matching_status_code
    }
  }
  tags = var.tags
}
##############
# WAF POLICY #
##############
resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = local.waf_policy_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags = var.tags

  policy_settings {
    enabled                     = local.waf_policy_enabled
    mode                        = local.waf_policy_mode
    request_body_check          = local.waf_policy_request_body_check
    max_request_body_size_in_kb = local.waf_policy_max_request_body_size_in_kb
    file_upload_limit_in_mb     = local.waf_policy_file_upload_limit_in_mb
  }

  managed_rules {
    managed_rule_set {
      type    = local.waf_policy_managed_rule_set_type
      version = local.waf_policy_managed_rule_set_version
    }
  }
}