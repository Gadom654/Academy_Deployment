### Azure Storage Account with Static Website Hosting for main origin ###

# Azure Storage Account
resource "azurerm_storage_account" "mainstorage" {
  name                     = "${var.prefix}sa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  network_rules {
    default_action = "Allow"
  }

  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }

  tags = var.tags
}

# Azure Storage Blob for index.html
resource "azurerm_storage_blob" "mainpage" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.mainstorage.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "./app/index.html"
  content_type           = "text/html"
}

# Azure Storage Blob for 404.html
resource "azurerm_storage_blob" "mainerrorpage" {
  name                   = "404.html"
  storage_account_name   = azurerm_storage_account.mainstorage.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "./app/404.html"
  content_type           = "text/html"
}

### Azure Storage Account with Static Website Hosting for error origin ###

# Azure Storage Account
resource "azurerm_storage_account" "errorstorage" {
  name                     = "${var.prefix}saerror"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  network_rules {
    default_action = "Allow"
  }

  static_website {
    index_document     = "5xx.html"
    error_404_document = "404.html"
  }

  tags = var.tags
}

# Azure Storage Blob for 5xx.html
resource "azurerm_storage_blob" "originerrorpage" {
  name                   = "5xx.html"
  storage_account_name   = azurerm_storage_account.errorstorage.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "./app/5xx.html"
  content_type           = "text/html"
}

# Azure Storage Blob for 404.html
resource "azurerm_storage_blob" "nferrorpage" {
  name                   = "404.html"
  storage_account_name   = azurerm_storage_account.errorstorage.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "./app/5xx.html"
  content_type           = "text/html"
}