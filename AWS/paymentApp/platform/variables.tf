variable "tags" {
  type        = map(string)
  description = "list of tags to add to each resource"
  default = {
    "project"     = "eks"
    "environment" = "production"
    "owner"       = "Dominik"
    "created_by"  = "Terraform"
  }
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-north-1"
}

# --- Label / Naming Variables ---
variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
  default     = "paymentapp"
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'jenkins'"
  default     = "platform"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'test'"
  default     = "prod"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between ID elements"
}

# --- Network Variables ---
variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones where subnets will be created"
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}