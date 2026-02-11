data "terraform_remote_state" "platform" {
  backend = "s3"
  config = {
    bucket = "terraform-states-gadom"
    key    = "paymentappplatform/terraform.tfstate"
    region = "eu-north-1"
  }
}