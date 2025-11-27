# ============================================================================
# Provisioner Module - Ansible Trigger and Inventory Generation
# ============================================================================

# ----------------------------------------------------------------------------
# Generate Dynamic Ansible Inventory File
# ----------------------------------------------------------------------------
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.root}/templates/inventory.tpl", {
    server_ip       = var.instance_public_ip
    ssh_user        = var.ssh_user
    ssh_private_key = var.ssh_private_key_path
    deploy_user     = var.deploy_user
    domain_name     = var.domain_name
  })

  filename        = "${path.root}/../ansible/inventory/hosts.yml"
  file_permission = "0644"
}

# ----------------------------------------------------------------------------
# Wait for SSH Connectivity
# ----------------------------------------------------------------------------
resource "null_resource" "wait_for_ssh" {
  depends_on = [local_file.ansible_inventory]

  provisioner "local-exec" {
    command = <<-EOT
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

  triggers = {
    instance_id = var.instance_id
  }
}

# ----------------------------------------------------------------------------
# Run Ansible Playbook
# ----------------------------------------------------------------------------
resource "null_resource" "run_ansible" {
  depends_on = [null_resource.wait_for_ssh]

  provisioner "local-exec" {
    command     = "ansible-playbook -i ${path.root}/../ansible/inventory/hosts.yml ${path.root}/../ansible/playbook.yml"
    working_dir = path.root
  }

  triggers = {
    instance_id = var.instance_id
  }
}