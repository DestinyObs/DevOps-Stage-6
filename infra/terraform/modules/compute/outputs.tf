# Compute Module Outputs

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_eip.app_eip.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "key_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.app_key.key_name
}
