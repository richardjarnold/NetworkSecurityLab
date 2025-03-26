output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "public_sg_id" {
  description = "Security Group ID for public"
  value       = aws_security_group.lab_public_sg.id
}

output "private_sg_id" {
  description = "Security Group ID for private"
  value       = aws_security_group.lab_private_sg.id
}