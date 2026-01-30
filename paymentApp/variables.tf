variable "prefix" {
  type        = string
  description = "The prefix which should be used for all resources in this example"
  default     = "example"
}

variable "location" {
  type        = string
  description = "The Azure Region in which all resources in this example should be created."
  default     = "westeurope"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
  default     = {}
}

variable "public_key" {
  type        = string
  description = "Your SSH public key (~/.ssh/id_rsa.pub)"
  sensitive   = true
}