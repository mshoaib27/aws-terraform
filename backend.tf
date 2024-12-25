terraform {
  backend "s3" {
    bucket         = "sba-terrafrom-backend"
    key            = "state/dev/terraform.tfstate"
    region         = "sa-east-1"
  }
}
