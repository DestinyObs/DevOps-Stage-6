# Compute Module Variables

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "subnet_id" {
  description = "Subnet ID for instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for instance"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

variable "deploy_user" {
  description = "User for deployment operations"
  type        = string
  default     = "deploy"
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 30
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
