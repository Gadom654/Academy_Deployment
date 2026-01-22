locals {
  kv_name     = "${var.prefix}-kv"
  kv_sku_name = "standard"
  kv_secret_permissions = [
    "Set",
    "Get",
    "List",
    "Delete",
    "Purge",
    "Recover"
  ]
  allow-eu_only_name                 = "${var.prefix}-allow-eu-only"
  allow-eu_only_policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  allow-eu_only_display_name         = "Enforce EU Regions Only"
  allow-eu_only_description          = "Restricts resource creation in this Resource Group to European regions only."
  allow-eu_only_parameters           = <<PARAMETERS
  {
  "listOfAllowedLocations": {
    "value": [
      "westeurope",
      "northeurope",
      "francecentral",
      "germanywestcentral"
    ]
  }
}
PARAMETERS
}