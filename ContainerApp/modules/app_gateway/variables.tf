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

variable "public_subnet_1_id" {
  type        = string
  description = "The ID of the public subnet to deploy the Application Gateway into."
}

variable "public_subnet_2_id" {
  type        = string
  description = "The ID of the second public subnet to deploy the Application Gateway into."
}
variable "app_1_url" {
  type        = string
  description = "The FQDN of the first backend application to route traffic to."
}
variable "app_2_url" {
  type        = string
  description = "The FQDN of the second backend application to route traffic to."
}