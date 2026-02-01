terraform {
  backend "s3" {
    bucket = "tasctower-terraform-backend"
    key    = "uat/terraform.tfstate"
    region = "eu-west-1"
  }
}
