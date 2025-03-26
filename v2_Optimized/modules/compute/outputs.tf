output "public_instance_ip" {
  description = "Public IP of the public EC2 instance"
  value       = aws_instance.lab_public_instance.public_ip
}

output "private_instance_ip" {
  description = "Private IP of the private EC2 instance"
  value       = aws_instance.lab_private_instance.private_ip
}