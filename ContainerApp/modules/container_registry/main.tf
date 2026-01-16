##################################
###     Container Registry     ###
################################## 
resource "azurerm_container_registry" "ContainerRegistry" {
  name                = local.container_registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = local.container_registry_sku_standard
  admin_enabled       = local.container_registry_admin_enabled
  tags                = var.tags
}
##################################
###       Container Image      ###
##################################
resource "azurerm_container_registry_task" "BuildFlaskImageTask" {
  container_registry_id = azurerm_container_registry.ContainerRegistry.id
  name                  = local.build_flask_image_task_name
  platform {
    os = local.platform_os
  }
  docker_step {
    dockerfile_path      = local.dockerfile_path
    context_path         = local.context_path
    context_access_token = local.access_token
    image_names          = local.image_names
  }
  tags = var.tags
}
resource "azurerm_container_registry_task_schedule_run_now" "BuildFlaskImageTaskRunNow" {
  container_registry_task_id = azurerm_container_registry_task.BuildFlaskImageTask.id
}