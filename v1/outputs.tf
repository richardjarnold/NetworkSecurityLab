# Output the public IP address of the public EC2 instance
output "public_instance_ip" {
  description = "Public IP of the public EC2 instance"
  value       = aws_instance.lab_public_instance.public_ip
}

# Output the private IP of the private EC2 instance
output "private_instance_ip" {
  description = "Private IP of the private EC2 instance"
  value       = aws_instance.lab_private_instance.private_ip
}