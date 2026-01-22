locals {
  #APPGateway
  AppGateway1PIPName                  = "${var.prefix}-appgw1-pip"
  AppGateway1Name                     = "${var.prefix}-appgw1"
  AppGatewaySKUName                   = "WAF_v2"
  AppGatewaySKUTier                   = "WAF_v2"
  AppGatewaySKUCapacity               = 2
  gateway1_ip_configuration_name      = "appGatewayIpConfig1"
  frontendPortName1                   = "appGatewayFrontendPort1"
  frontendPort                        = 80
  frontendIPConfigName1               = "appGatewayFrontendIPConfig1"
  backendAddressPoolName1             = "appGatewayBackendPool1"
  backendHttpSettingsName1            = "appGatewayBackendHttpSettings1"
  is_cookie_based_affinity_enabled    = "Disabled"
  backendHttpSettingsPort             = 80
  backendHttpSettingsProtocol         = "Http"
  backendHttpSettingsRequestTimeout   = 20
  backendHttpSettingsPath             = "/"
  httpListenerName1                   = "appGatewayHttpListener1"
  httpListenerProtocol                = "Http"
  routingRuleName1                    = "appGatewayRoutingRule1"
  routingRuleType                     = "Basic"
  IP_allocation_method                = "Static"
  routingRulePriority                 = 1
  probeName1                          = "appGatewayProbe1"
  probeProtocol                       = "Http"
  probePath                           = "/health"
  probeInterval                       = 10
  probeTimeout                        = 10
  probeUnhealthyThreshold             = 3
  probePort                           = 80
  pickhostnamefrombackendhttpsettings = true
  probeName2                          = "appGatewayProbe2"
  matching_status_code                = ["200-399"]
  #WAF
  waf_policy_name                        = "${var.prefix}-waf"
  waf_policy_enabled                     = true
  waf_policy_mode                        = "Prevention"
  waf_policy_request_body_check          = true
  waf_policy_max_request_body_size_in_kb = 128
  waf_policy_file_upload_limit_in_mb     = 100
  waf_policy_managed_rule_set_type       = "OWASP"
  waf_policy_managed_rule_set_version    = "3.2"
}