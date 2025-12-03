# Latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# SSH key pair
resource "aws_key_pair" "app_key" {
  key_name   = "${var.project_name}-key"
  public_key = var.ssh_public_key

  tags = var.common_tags
}

# EC2 instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.app_key.key_name

  # Prepare instance for Ansible
  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              apt-get update
              apt-get upgrade -y
              apt-get install -y python3 python3-pip
              
              useradd -m -s /bin/bash ${var.deploy_user}
              usermod -aG sudo ${var.deploy_user}
              echo "${var.deploy_user} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
              
              mkdir -p /home/${var.deploy_user}/.ssh
              cp /home/ubuntu/.ssh/authorized_keys /home/${var.deploy_user}/.ssh/
              chown -R ${var.deploy_user}:${var.deploy_user} /home/${var.deploy_user}/.ssh
              chmod 700 /home/${var.deploy_user}/.ssh
              chmod 600 /home/${var.deploy_user}/.ssh/authorized_keys
              
              echo "Instance ready for Ansible" > /tmp/user_data_complete
              EOF

  # Root volume
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true

    tags = merge(var.common_tags, {
      Name = "${var.project_name}-root-volume"
    })
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-app-server"
  })
}

# Elastic IP
resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-eip"
  })
}

# Wait for instance initialization
resource "null_resource" "wait_for_instance" {
  depends_on = [aws_instance.app_server]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}
