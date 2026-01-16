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

variable "app_1_domain" {
  type        = string
  description = "The custom domain for Container App 1."
}

variable "app_2_domain" {
  type        = string
  description = "The custom domain for Container App 2."
}
variable "container_app_env_1_ip" {
  type        = string
  description = "The internal IP address of the Container App Environment 1."
}
variable "container_app_env_2_ip" {
  type        = string
  description = "The internal IP address of the Container App Environment 1."
}
variable "app_gateway_1_public_ip" {
  type        = string
  description = "The public IP address of Application Gateway 1."
}
variable "app_gateway_2_public_ip" {
  type        = string
  description = "The public IP address of Application Gateway 2."
}