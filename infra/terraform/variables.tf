# Terraform Variables

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-stage6"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "owner_email" {
  description = "Email of the project owner (for drift notifications)"
  type        = string
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "AWS availability zone"
  type        = string
  default     = "us-east-1a"
}

# Networking Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_allowed_ips" {
  description = "List of IP addresses allowed to SSH (restrict to your IP)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change this to your IP for security
}

# Compute Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 30
}

# SSH Configuration
variable "ssh_public_key" {
  description = "SSH public key content for EC2 access"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key file"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for initial connection"
  type        = string
  default     = "ubuntu"
}

variable "deploy_user" {
  description = "User for application deployment"
  type        = string
  default     = "deploy"
}

# Application Configuration
variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "destinyobs.mooo.com"
}
