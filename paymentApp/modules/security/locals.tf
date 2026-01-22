locals {
  kv_name = "${var.prefix}-kv"
  kv_sku_name = "standard"
  kv_secret_permissions = [
      "Set",
      "Get",
      "List",
      "Delete",
      "Purge",
      "Recover"
    ]
}