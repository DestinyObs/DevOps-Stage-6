terraform {
  backend "s3" {
    bucket  = "devops-stage6-terraform-state-destinyobs"
    key     = "prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
