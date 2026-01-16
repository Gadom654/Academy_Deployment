##################################
###     Container App Envs     ###
##################################
resource "azurerm_container_app_environment" "PrivateContainerAppEnv1" {
  name                           = local.container_app_env_name1
  location                       = var.location
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  internal_load_balancer_enabled = local.is_internal_load_balancer_enabled

  public_network_access              = local.public_network_access_disabled
  infrastructure_resource_group_name = local.ContainerEnv1RG_name

  workload_profile {
    name                  = local.workload_name
    workload_profile_type = local.workload_type
    minimum_count         = local.count
    maximum_count         = local.count
  }
  logs_destination           = local.container_app_logs_destination
  log_analytics_workspace_id = var.container_law_id
  infrastructure_subnet_id   = var.private_subnet_1_id
}
resource "azurerm_container_app_environment" "PrivateContainerAppEnv2" {
  name                           = local.container_app_env_name2
  location                       = var.location
  resource_group_name            = var.resource_group_name
  tags                           = var.tags
  internal_load_balancer_enabled = local.is_internal_load_balancer_enabled

  public_network_access              = local.public_network_access_disabled
  infrastructure_resource_group_name = local.ContainerEnv2RG_name

  workload_profile {
    name                  = local.workload_name
    workload_profile_type = local.workload_type
    minimum_count         = local.count
    maximum_count         = local.count
  }
  logs_destination           = local.container_app_logs_destination
  log_analytics_workspace_id = var.container_law_id
  infrastructure_subnet_id   = var.private_subnet_2_id
}
##################################
###     Container Apps         ###
##################################
resource "azurerm_container_app" "PrivateContainerApp1" {
  name                         = local.container_app_name1
  resource_group_name          = var.resource_group_name
  tags                         = var.tags
  container_app_environment_id = azurerm_container_app_environment.PrivateContainerAppEnv1.id
  workload_profile_name        = local.workload_name
  revision_mode                = local.container_revision_mode

  secret {
    name  = local.container_registry_password_name1
    value = var.container_registry_admin_password
  }

  registry {
    server               = var.container_image_registry_server
    username             = var.container_registry_admin_username
    password_secret_name = local.container_registry_password_name1
  }

  template {
    container {
      name   = local.container_name1
      image  = var.container_image_url
      cpu    = local.container_cpu
      memory = local.container_memory
    }
    min_replicas = local.min_replicas
    max_replicas = local.max_replicas
    custom_scale_rule {
      custom_rule_type = local.custom_rule_type
      metadata = {
        type  = local.metadata_type
        value = local.metadata_value
      }
      name = local.custom_scale_rule_name
    }
  }
  ingress {
    allow_insecure_connections = local.ingress_allow_insecure_connections
    external_enabled           = local.isexternal_enabled
    target_port                = local.container_port
    transport                  = local.transport_protocol
    traffic_weight {
      percentage      = local.traffic_percentage
      latest_revision = local.traffic_latest_revision
    }
  }
}
resource "azurerm_container_app" "PrivateContainerApp2" {
  name                         = local.container_app_name2
  resource_group_name          = var.resource_group_name
  tags                         = var.tags
  container_app_environment_id = azurerm_container_app_environment.PrivateContainerAppEnv2.id
  workload_profile_name        = local.workload_name
  revision_mode                = local.container_revision_mode

  secret {
    name  = local.container_registry_password_name2
    value = var.container_registry_admin_password
  }

  registry {
    server               = var.container_image_registry_server
    username             = var.container_registry_admin_username
    password_secret_name = local.container_registry_password_name2
  }

  template {
    container {
      name   = local.container_name2
      image  = var.container_image_url
      cpu    = local.container_cpu
      memory = local.container_memory
    }
  }
  ingress {
    allow_insecure_connections = local.ingress_allow_insecure_connections
    external_enabled           = local.isexternal_enabled
    target_port                = local.container_port
    transport                  = local.transport_protocol
    traffic_weight {
      percentage      = local.traffic_percentage
      latest_revision = local.traffic_latest_revision
    }
  }
}
##################################
### Azure monitor autoscailing ###
##################################
# resource "azurerm_monitor_autoscale_setting" "PrivateContainerApp1as" {
#   name                = local.private_container_app_name1-autoscale
#   resource_group_name = var.resource_group_name
#   target_resource_id  = azurerm_container_app.PrivateContainerApp1.id
#   location            = var.location
#   tags                = var.tags
#   profile {
#     name = local.autoscale_profile_1_name
#     capacity {
#       minimum = tostring(local.min_replicas)
#       maximum = tostring(local.max_replicas)
#       default = tostring(local.min_replicas)
#     }
#     rule {
#       metric_trigger {
#         metric_name        = local.autoscaling_metric_name
#         metric_resource_id = azurerm_container_app.PrivateContainerApp1.id
#         time_grain         = local.monitoring_time_grain
#         statistic          = local.monitoring_statistic
#         time_window        = local.monitoring_time_window
#         time_aggregation   = local.monitoring_time_aggregation
#         operator           = local.autoscaling_operator_greater
#         threshold          = local.autoscaling_threshold_high
#       }
#       scale_action {
#         direction = local.scale_up_direction
#         type      = local.scale_up_type
#         value     = local.scale_up_value
#         cooldown  = local.scale_up_cooldown
#       }
#     }
#     rule {
#       metric_trigger {
#         metric_name        = local.autoscaling_metric_name
#         metric_resource_id = azurerm_container_app.PrivateContainerApp1.id
#         time_grain         = local.monitoring_time_grain
#         statistic          = local.monitoring_statistic
#         time_window        = local.monitoring_time_window
#         time_aggregation   = local.monitoring_time_aggregation
#         operator           = local.autoscaling_operator_less
#         threshold          = local.autoscaling_threshold_low
#       }
#       scale_action {
#         direction = local.scale_down_direction
#         type      = local.scale_down_type
#         value     = local.scale_down_value
#         cooldown  = local.scale_down_cooldown
#       }
#     }
#   }
# }
# resource "azurerm_monitor_autoscale_setting" "PrivateContainerApp2as" {
#   name                = local.private_container_app_name2-autoscale
#   resource_group_name = var.resource_group_name
#   target_resource_id  = azurerm_container_app.PrivateContainerApp2.id
#   location            = var.location
#   tags                = var.tags
#   profile {
#     name = local.autoscale_profile_2_name
#     capacity {
#       minimum = tostring(local.min_replicas)
#       maximum = tostring(local.max_replicas)
#       default = tostring(local.min_replicas)
#     }
#     rule {
#       metric_trigger {
#         metric_name        = local.autoscaling_metric_name
#         metric_resource_id = azurerm_container_app.PrivateContainerApp2.id
#         time_grain         = local.monitoring_time_grain
#         statistic          = local.monitoring_statistic
#         time_window        = local.monitoring_time_window
#         time_aggregation   = local.monitoring_time_aggregation
#         operator           = local.autoscaling_operator_greater
#         threshold          = local.autoscaling_threshold_high
#       }
#       scale_action {
#         direction = local.scale_up_direction
#         type      = local.scale_up_type
#         value     = local.scale_up_value
#         cooldown  = local.scale_up_cooldown
#       }
#     }
#     rule {
#       metric_trigger {
#         metric_name        = local.autoscaling_metric_name
#         metric_resource_id = azurerm_container_app.PrivateContainerApp2.id
#         time_grain         = local.monitoring_time_grain
#         statistic          = local.monitoring_statistic
#         time_window        = local.monitoring_time_window
#         time_aggregation   = local.monitoring_time_aggregation
#         operator           = local.autoscaling_operator_less
#         threshold          = local.autoscaling_threshold_low
#       }
#       scale_action {
#         direction = local.scale_down_direction
#         type      = local.scale_down_type
#         value     = local.scale_down_value
#         cooldown  = local.scale_down_cooldown
#       }
#     }
#   }
# }
