output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.networking.security_group_id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.compute.instance_id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.compute.instance_public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.compute.instance_private_ip
}

output "application_url" {
  description = "Application URL"
  value       = "https://${var.domain_name}"
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh -i ${var.ssh_private_key_path} ${var.ssh_user}@${module.compute.instance_public_ip}"
}

output "ansible_inventory_path" {
  description = "Path to generated Ansible inventory"
  value       = module.provisioner.inventory_file_path
}

output "deployment_status" {
  description = "Status of Ansible deployment"
  value       = module.provisioner.ansible_triggered ? "Ansible executed successfully" : "Ansible not triggered"
}
