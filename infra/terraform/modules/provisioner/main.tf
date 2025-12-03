# Generate Ansible inventory
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

# Wait for SSH
resource "null_resource" "wait_for_ssh" {
  depends_on = [local_file.ansible_inventory]

  provisioner "local-exec" {
    command = "bash ${path.root}/scripts/wait_for_ssh.sh ${var.ssh_private_key_path} ${var.ssh_user} ${var.instance_public_ip}"
  }

  triggers = {
    instance_id = var.instance_id
  }
}

# Run Ansible
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