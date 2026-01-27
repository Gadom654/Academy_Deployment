locals {
  kv_name     = "${var.prefix}-kv"
  kv_sku_name = "standard"
  applyID     = "1f07b8c9-4028-4856-bb87-c71b202ecacf"
  fluxacruser = "35b4a429-fcc0-4864-8618-d577a3f7da10"

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