# Define the provider and the region to use
provider "aws" {
  region = "us-east-1" # AWS Region
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
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

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

# Create a Route Table for public
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

# Create a Route Table for the Private Subnet
resource "aws_route_table" "lab_private_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "Lab-RT-Private"
  }
}

# Associate the Private Route Table with the Private Subnet
resource "aws_route_table_association" "lab_private_rt_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.lab_private_rt.id
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

# Network ACL for Public Subnet
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "Lab-NACL-Public"
  }
}

# Inbound SSH from anywhere
resource "aws_network_acl_rule" "public_inbound_ssh" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

# Inbound ephemeral ports (for return traffic)
resource "aws_network_acl_rule" "public_inbound_ephemeral" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Outbound all traffic
resource "aws_network_acl_rule" "public_outbound_all" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# Associate Public NACL with Public Subnet
resource "aws_network_acl_association" "public_nacl_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  network_acl_id = aws_network_acl.public_nacl.id
}

# Network ACL for Private Subnet
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "Lab-NACL-Private"
  }
}

# Inbound from public subnet (all ports for simplicity)
resource "aws_network_acl_rule" "private_inbound_from_public" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "10.0.1.0/24"
  from_port      = 0
  to_port        = 65535
}

# Inbound ephemeral (for return SSH or other TCP responses)
resource "aws_network_acl_rule" "private_inbound_ephemeral" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.1.0/24"
  from_port      = 1024
  to_port        = 65535
}

# Outbound to public subnet
resource "aws_network_acl_rule" "private_outbound_to_public" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "10.0.1.0/24"
  from_port      = 0
  to_port        = 65535
}

# Outbound ephemeral ports
resource "aws_network_acl_rule" "private_outbound_ephemeral" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.1.0/24"
  from_port      = 1024
  to_port        = 65535
}

# Associate Private NACL with Private Subnet
resource "aws_network_acl_association" "private_nacl_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  network_acl_id = aws_network_acl.private_nacl.id
}
