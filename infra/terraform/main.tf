# Root infrastructure configuration
# Modules: networking, compute, provisioner

# Provider requirements
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Common tags for all resources
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    DriftCheck  = "enabled"
    Owner       = var.owner_email
  }
}

# Networking module
module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
  ssh_allowed_ips    = var.ssh_allowed_ips
  common_tags        = local.common_tags
}

# Compute module
module "compute" {
  source = "./modules/compute"

  project_name      = var.project_name
  instance_type     = var.instance_type
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.networking.security_group_id
  ssh_public_key    = var.ssh_public_key
  deploy_user       = var.deploy_user
  root_volume_size  = var.root_volume_size
  common_tags       = local.common_tags

  depends_on = [module.networking]
}

# Provisioner module - Ansible integration
module "provisioner" {
  source = "./modules/provisioner"

  instance_id          = module.compute.instance_id
  instance_public_ip   = module.compute.instance_public_ip
  ssh_user             = var.ssh_user
  ssh_private_key_path = var.ssh_private_key_path
  deploy_user          = var.deploy_user
  domain_name          = var.domain_name

  depends_on = [module.compute]
}
