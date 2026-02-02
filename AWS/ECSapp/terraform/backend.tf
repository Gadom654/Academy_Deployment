terraform {
  backend "s3" {
    bucket       = "terraform-states-gadom"
    key          = "ecs/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}