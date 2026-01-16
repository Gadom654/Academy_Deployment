## Prefix Variable
variable "prefix" {
  type        = string
  description = "The prefix which should be used for all resources in this example"
}

## Location Variable
variable "location" {
  type        = string
  description = "The Azure Region in which all resources in this example should be created."
}

## Tags Variable
variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
  default     = {}
}

## Existing Resource Group Name Variable
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the storage account."
}

### Variables for Static Web App CDN Integration ###
## New variable for the Storage Account ID
variable "storage_account_id" {
  type        = string
  description = "The ID of the Storage Account"
}

## New variable for the Storage Account primary web host
variable "storage_primary_web_host" {
  type        = string
  description = "The primary web host of the Storage Account"
}

## New variable for the Error Storage Account ID
variable "error_storage_account_id" {
  type        = string
  description = "The ID of the Error Storage Account"
}

## New variable for the Error Storage Account primary web host
variable "error_storage_web_host" {
  type        = string
  description = "The primary web host of the Error Storage Account"
}