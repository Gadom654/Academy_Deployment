terraform {
  backend "s3" {
    bucket       = "terraform-states-gadom"
    key          = "eks/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}