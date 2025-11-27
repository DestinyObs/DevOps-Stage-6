# Terraform Backend Configuration
# Comment this out for initial setup, then uncomment after creating S3 bucket

terraform {
  backend "s3" {
    bucket         = "devops-stage6-terraform-state-destinyobs"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "devops-stage6-terraform-lock"
  }
}

# To initialize:
# 1. Comment out this entire backend block
# 2. Run: terraform init
# 3. Create S3 bucket and DynamoDB table manually or with separate script
# 4. Uncomment this block
# 5. Run: terraform init -migrate-state
