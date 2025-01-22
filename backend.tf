terraform {
/*   backend "s3" {
    bucket         = "sba-terrafrom-backend"
    key            = "state/dev/terraform.tfstate"
    region         = "sa-east-1"
  } */
    backend "s3" {
    bucket         = "sba-terraform-backend-prod"
    key            = "state/prod/terraform.tfstate"
    region         = "sa-east-1"
  }
}

