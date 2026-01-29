######################
# Karpenter identity #
######################
resource "azurerm_resource_group" "identity_group" {
  name     = local.uai-group_name
  location = var.location
  tags     = var.tags
}
resource "azurerm_user_assigned_identity" "karpenter" {
  name                = local.karpenter_uai_name
  resource_group_name = azurerm_resource_group.identity_group.name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "karpenter_network" {
  scope                = local.subscription_id
  role_definition_name = local.karpenter_network_role_definition_name
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}

resource "azurerm_role_assignment" "karpenter_vm_operator" {
  scope                = local.subscription_id
  role_definition_name = local.karpenter_vm_operator_role_definition_name
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}

resource "azurerm_role_assignment" "karpenter_vm_contributor" {
  scope                = local.subscription_id
  role_definition_name = local.karpenter_vm_contributor_role_definition_name
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}
