variable "prefix" {
  type        = string
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  type        = string
  description = "The Azure Region in which all resources in this example should be created."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
  default     = {}
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the storage account."
}

variable "admin_username" {
  description = "Database administrator username"
  type        = string
  default     = "pgadmin"
}

variable "vnet_id" {
  description = "The ID of the VNet to link the Private DNS Zone to"
  type        = string
}
variable "key_vault_id" {
  description = "The ID of the Key Vault"
  type        = string
}

variable "public_key" {
  type        = string
  description = "Your SSH public key (~/.ssh/id_rsa.pub)"
  sensitive   = true
}

variable "subnet2_id" {
  type        = string
  description = "The ID of the 2nd DB subnet"
}