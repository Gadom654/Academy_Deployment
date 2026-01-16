variable "prefix" {
  type        = string
  description = "The prefix which should be used for all resources in this example"
  default     = "test"
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
