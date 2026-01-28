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
  resource_group_name = azurerm_resource_group.ContainerAppRG.name
  aks_subnet_id       = module.network.private_subnet_1_id
  vnet_id             = module.network.vnet_id
}

##################################
### Security Module           ###
##################################
module "security" {
  source              = "./modules/security"
  prefix              = var.prefix
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.ContainerAppRG.name
  resource_group_id   = azurerm_resource_group.ContainerAppRG.id
}

##################################
###  Network Module            ###
##################################
module "network" {
  source              = "./modules/network"
  prefix              = var.prefix
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.ContainerAppRG.name
}

##################################
###  monitoring Module         ###
##################################
module "monitoring" {
  source              = "./modules/monitoring"
  prefix              = var.prefix
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.ContainerAppRG.name
  k8s_cluster_id      = module.AKS.k8s_cluster_id
}

##################################
###  database Module            ###
##################################
module "database" {
  source              = "./modules/database"
  prefix              = var.prefix
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.ContainerAppRG.name
  subnet_id           = module.network.private_subnet_2_id
  key_vault_id        = module.security.key_vault_id
  vnet_id             = module.network.vnet_id
  law_id              = module.monitoring.law_id
}

###############################
###  bastion Module         ###
###############################
module "bastion" {
  source              = "./modules/bastion"
  prefix              = var.prefix
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.ContainerAppRG.name
  bastion_subnet_id   = module.network.public_subnet_2_id
}

###########################
###  AKS Module         ###
###########################
module "AKS" {
  source                = "./modules/AKS"
  prefix                = var.prefix
  location              = var.location
  tags                  = var.tags
  resource_group_name   = azurerm_resource_group.ContainerAppRG.name
  aks_subnet_id         = module.network.private_subnet_1_id
  law_id                = module.monitoring.law_id
  gateway_id            = module.app_gateway.gateway_id
  resource_group_id     = azurerm_resource_group.ContainerAppRG.id
  container_registry_id = module.container_registry.acr_id
}

##################################
###  App Gateway Module        ###
##################################
module "app_gateway" {
  source              = "./modules/app_gateway"
  prefix              = var.prefix
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.ContainerAppRG.name
  public_subnet_1_id  = module.network.public_subnet_1_id
}
