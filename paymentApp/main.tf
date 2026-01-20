##################################
###       Resource Group       ###
##################################
resource "azurerm_resource_group" "ContainerAppRG" {
  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

##################################
### Container Registry Module  ###
##################################
module "container_registry" {
  source              = "./modules/container_registry"
  prefix              = var.prefix
  location            = var.location
  tags                = var.tags
  resource_group_name = local.resource_group_name
  github_access_token = var.github_access_token
}