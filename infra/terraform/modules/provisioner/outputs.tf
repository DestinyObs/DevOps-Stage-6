# Provisioner Module Outputs

output "inventory_file_path" {
  description = "Path to generated Ansible inventory file"
  value       = local_file.ansible_inventory.filename
}

output "ansible_triggered" {
  description = "Indicates if Ansible was triggered"
  value       = null_resource.run_ansible.id != "" ? true : false
}
