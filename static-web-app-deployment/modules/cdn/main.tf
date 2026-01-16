# Azure Front Door Profile
resource "azurerm_cdn_frontdoor_profile" "example" {
  name                     = "${var.prefix}-profile"
  resource_group_name      = var.resource_group_name
  sku_name                 = "Standard_AzureFrontDoor"
  response_timeout_seconds = 120

  tags = var.tags
}

# Azure Front Door Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "example" {
  name                     = "${var.prefix}-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.example.id
  enabled                  = true

  tags = var.tags
}

# Azure Front Door Origin Group
resource "azurerm_cdn_frontdoor_origin_group" "example" {
  name                                                      = "${var.prefix}-origin-group"
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.example.id
  session_affinity_enabled                                  = false
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 1

  health_probe {
    interval_in_seconds = 2
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 5
    successful_samples_required        = 3
  }
}

# Azure Front Door Origin pointing to the Static Web App
resource "azurerm_cdn_frontdoor_origin" "example" {
  name                          = "${var.prefix}-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.example.id
  enabled                       = true

  certificate_name_check_enabled = true # Required for Private Link
  host_name                      = var.storage_primary_web_host
  origin_host_header             = var.storage_primary_web_host
  priority                       = 1
  weight                         = 500

}

# Azure Front Door Origin pointing to the Static Web App Error Origin
resource "azurerm_cdn_frontdoor_origin" "errororigin" {
  name                          = "${var.prefix}-errororigin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.example.id
  enabled                       = true

  certificate_name_check_enabled = true # Required for Private Link
  host_name                      = var.error_storage_web_host
  origin_host_header             = var.error_storage_web_host
  priority                       = 2
  weight                         = 500

}

# Azure Front Door Route to map requests to the Static Web App origin
resource "azurerm_cdn_frontdoor_route" "example" {
  name                          = "${var.prefix}-example-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.example.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.example.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.example.id]
  enabled                       = true

  forwarding_protocol    = "MatchRequest"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

}

# Azure Front Door WAF Policy with Rate Limiting
resource "azurerm_cdn_frontdoor_firewall_policy" "RateLimitPolicy" {
  name                              = "${var.prefix}wafpolicy"
  mode                              = local.WAF_MODE
  resource_group_name               = var.resource_group_name
  sku_name                          = azurerm_cdn_frontdoor_profile.example.sku_name
  enabled                           = true
  custom_block_response_status_code = 403
  custom_block_response_body        = "QWNjZXNzIGRlbmllZCBkdWUgdG8gcmF0ZSBsaW1pdGluZy4gUGxlYXNlIHRyeSBhZ2FpbiBsYXRlci4="

  tags = var.tags

  custom_rule {
    name                           = "RateLimitRule"
    type                           = "RateLimitRule"
    enabled                        = true
    priority                       = 1000
    action                         = "Block"
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 100

    match_condition {
      match_variable     = "RemoteAddr"
      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["0.0.0.0/0", "::/0"]
    }
  }
}

# Azure Front Door Security Policy
resource "azurerm_cdn_frontdoor_security_policy" "FDRateLimitPolicy" {
  name                     = "${var.prefix}-security-policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.example.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.RateLimitPolicy.id
      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.example.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}