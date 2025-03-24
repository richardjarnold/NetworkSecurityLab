# Public EC2 Instance
resource "aws_instance" "lab_public_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.public_sg_id]

  tags = merge(var.tags, {
    Name = "Lab-Instance-Public"
  })
}

# Private EC2 Instance
resource "aws_instance" "lab_private_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.private_sg_id]

  tags = merge(var.tags, {
    Name = "Lab-Instance-Private"
  })
}