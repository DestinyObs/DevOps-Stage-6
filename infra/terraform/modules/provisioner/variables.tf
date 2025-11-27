# Provisioner Module Variables

variable "instance_id" {
  description = "ID of the EC2 instance"
  type        = string
}

variable "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for connecting to instance"
  type        = string
  default     = "ubuntu"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
}

variable "deploy_user" {
  description = "User for deployment operations"
  type        = string
  default     = "deploy"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}
