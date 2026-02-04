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
  default     = "eks"
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'jenkins'"
  default     = "eks"
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
  default     = ["eu-north-1a", "eu-north-1b"]
}

# --- EKS Cluster Variables ---
variable "kubernetes_version" {
  type        = string
  default     = "1.34"
  description = "Desired Kubernetes master version"
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "should be there a private endpoint for eks"
}

variable "endpoint_public_access" {
  type        = bool
  default     = false
  description = "should be there a private endpoint for eks"
}


variable "vpc_cni_version" {
  type        = string
  default     = null
  description = "Addon version for vpc-cni"
}

variable "vpc_cni_service_account_role_arn" {
  type        = string
  default     = null
  description = "The ARN of the IAM role for the VPC CNI service account"
}

variable "kube_proxy_version" {
  type        = string
  default     = null
  description = "Addon version for kube-proxy"
}

variable "coredns_version" {
  type        = string
  default     = null
  description = "Addon version for coredns"
}

# --- EKS Node Group Variables ---
variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type for the EKS worker nodes"
}

variable "desired_size" {
  type        = number
  default     = 1
  description = "Desired number of nodes in the Node Group"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Minimum number of nodes in the Node Group"
}

variable "max_size" {
  type        = number
  default     = 2
  description = "Maximum number of nodes in the Node Group"
}

variable "autoscaling_policies_enabled" {
  type        = bool
  default     = true
  description = "Whether to create local IAM policy for the cluster autoscaler"
}

variable "ami_type" {
  type        = string
  default     = "AL2023_x86_64_STANDARD"
  description = "Ami type used in EKS node group"
}

#Bastion Variables
variable "user_data" {
  type        = list(string)
  default     = []
  description = "User data content"
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
  description = "Whether to associate public IP to the instance."
}