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

variable "container_law_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace for the Container App."
}

variable "private_subnet_1_id" {
  type        = string
  description = "The ID of the first private subnet for the Container App Environment."
}

variable "private_subnet_2_id" {
  type        = string
  description = "The ID of the second private subnet for the Container App Environment."
}

variable "container_image_url" {
  type        = string
  description = "The URL of the container image to be used in the Container App."
}
variable "container_image_registry_server" {
  type        = string
  description = "The container registry server for the container image."
}
variable "container_registry_admin_username" {
  type        = string
  description = "The admin username for the container registry."
}
variable "container_registry_admin_password" {
  type        = string
  description = "The admin password for the container registry."
}