# ============================================================================
# Provisioner Module - Ansible Trigger and Inventory Generation
# ============================================================================
# This module handles the bridge between Terraform and Ansible:
# - Generates dynamic Ansible inventory from Terraform outputs
# - Waits for SSH connectivity before proceeding
# - Automatically triggers Ansible playbook execution
# - Ensures idempotent deployment (only runs when needed)
# ============================================================================

# ----------------------------------------------------------------------------
# Generate Dynamic Ansible Inventory File
# ----------------------------------------------------------------------------
# Creates a YAML inventory file for Ansible using Terraform outputs
# This eliminates manual inventory management and ensures accuracy
resource "local_file" "ansible_inventory" {
  # Use template file to generate inventory with variables
  content = templatefile("${path.root}/templates/inventory.tpl", {
    server_ip       = var.instance_public_ip      # EC2 public IP
    ssh_user        = var.ssh_user                # Initial SSH user (ubuntu)
    ssh_private_key = var.ssh_private_key_path    # Path to SSH private key
    deploy_user     = var.deploy_user             # Application deployment user
    domain_name     = var.domain_name             # Application domain
  })

  # Write inventory to ansible directory
  filename        = "${path.root}/../ansible/inventory/hosts.yml"
  file_permission = "0644"                        # Read/write for owner, read for others
}

# ----------------------------------------------------------------------------
# Wait for SSH Connectivity
# ----------------------------------------------------------------------------
# Polls the instance until SSH is ready and accepting connections
# Prevents Ansible from failing due to premature execution
resource "null_resource" "wait_for_ssh" {
  depends_on = [local_file.ansible_inventory]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      echo "Waiting for SSH to be ready..."
      max_attempts=30
      attempt=0
      while [ $attempt -lt $max_attempts ]; do
        if ssh -i ${var.ssh_private_key_path} -o StrictHostKeyChecking=no -o ConnectTimeout=5 ${var.ssh_user}@${var.instance_public_ip} "echo 'SSH is ready'" 2>/dev/null; then
          echo "SSH connection successful!"
          exit 0
        fi
        attempt=$((attempt + 1))
        echo "Attempt $attempt/$max_attempts failed. Retrying in 10 seconds..."
        sleep 10
      done
      echo "Failed to connect via SSH after $max_attempts attempts"
      exit 1
    EOT
  }

  # Trigger when instance ID changes (new instance created)
  triggers = {
    instance_id = var.instance_id
  }
}

# ----------------------------------------------------------------------------
# Run Ansible Playbook
# ----------------------------------------------------------------------------
# Executes the Ansible playbook to configure and deploy the application
# Only runs when instance changes or inventory is updated (idempotent)
resource "null_resource" "run_ansible" {
  depends_on = [null_resource.wait_for_ssh]

  provisioner "local-exec" {
    # Run ansible-playbook with generated inventory
    command     = "ansible-playbook -i ${path.root}/../ansible/inventory/hosts.yml ${path.root}/../ansible/playbook.yml"
    working_dir = path.root
  }

  # ----------------------------------------------------------------------------
  # Idempotency Triggers
  # ----------------------------------------------------------------------------
  # Terraform will only re-run Ansible when these values change:
  # - instance_id: New instance created
  # - inventory: Inventory configuration changed
  # If neither changes, Ansible won't run (making it idempotent)
  triggers = {
    instance_id = var.instance_id                # Trigger on new instance
    inventory   = local_file.ansible_inventory.content  # Trigger on inventory change
  }
}
