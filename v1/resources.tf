# Add an SSH key pair
resource "aws_key_pair" "lab_key" {
  key_name   = "lab-key"
  public_key = file("C:/Users/rarnold/ssh-keys/lab-key.pub")

  tags = {
    Name = "Lab-Key-Pair"
  }
}

# Deploy a public EC2 instance
resource "aws_instance" "lab_public_instance" {
  ami                    = "ami-04aa00acb1165b32a"
  instance_type          = "t2.micro" 
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = aws_key_pair.lab_key.key_name
  vpc_security_group_ids = [aws_security_group.lab_public_sg.id]

  tags = {
    Name = "Lab-Instance-Public"
  }
}

# Deploy a private EC2 instance
resource "aws_instance" "lab_private_instance" {
  ami                    = "ami-04aa00acb1165b32a"
  instance_type          = "t2.micro" 
  subnet_id              = aws_subnet.private_subnet.id
  key_name               = aws_key_pair.lab_key.key_name
  vpc_security_group_ids = [aws_security_group.lab_private_sg.id]

  tags = {
    Name = "Lab-Instance-Private"
  }
}