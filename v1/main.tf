# Define the provider and the region to use
provider "aws" {
  region = "us-east-1"  # AWS Region
}

# Create VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Lab-VPC"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Lab-Subnet-Public"
  }
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "Lab-Subnet-Private"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "Lab-IGW"
  }
}

# Create a Route Table
resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }

  tags = {
    Name = "Lab-RT-Public"
  }
}

# Create route table association
resource "aws_route_table_association" "lab_public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}

# Security Group for Public
resource "aws_security_group" "lab_public_sg" {
  name        = "Lab-Public-SG"
  description = "Allow SSH access from the Internet"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description = "SSH from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lab-SG-Public"
  }
}

# Security Group for Private
resource "aws_security_group" "lab_private_sg" {
  name        = "Lab-Private-SG"
  description = "Allow traffic between private and public"
  vpc_id      = aws_vpc.lab_vpc.id  

  ingress {
    description = "Allow traffic between private and public (not internet)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lab-SG-Private"
  }
}