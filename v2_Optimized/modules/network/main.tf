# Create VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block = var.vpc_cidr

  tags = merge(var.tags, {
    Name = "Lab-VPC"
  })
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.public_availability_zone
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "Lab-Subnet-Public"
  })
}

# Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.private_availability_zone
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "Lab-Subnet-Private"
  })
}

# Create Internet Gateway
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = merge(var.tags, {
    Name = "Lab-IGW"
  })
}

# Create Route Table for Public Subnet
resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }

  tags = merge(var.tags, {
    Name = "Lab-RT-Public"
  })
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "lab_public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}

# Public Security Group
resource "aws_security_group" "lab_public_sg" {
  name        = "Lab-Public-SG"
  description = "Allow SSH access from the internet"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description = "SSH from anywhere"
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

  tags = merge(var.tags, {
    Name = "Lab-Public-SG"
  })
}

# Private Security Group – Internal Traffic Only
resource "aws_security_group" "lab_private_sg" {
  name        = "Lab-Private-SG"
  description = "Allow traffic between public and private subnets"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description = "Allow internal traffic from subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_subnet_cidr, var.private_subnet_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "Lab-Private-SG"
  })
}

# Network ACL for Public Subnet
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = merge(var.tags, {
    Name = "Lab-NACL-Public"
  })
}

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

resource "aws_network_acl_association" "public_nacl_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  network_acl_id = aws_network_acl.public_nacl.id
}

# Network ACL for Private Subnet
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = merge(var.tags, {
    Name = "Lab-NACL-Private"
  })
}

resource "aws_network_acl_rule" "private_inbound_from_public" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.public_subnet_cidr
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "private_outbound_to_public" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.public_subnet_cidr
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_association" "private_nacl_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  network_acl_id = aws_network_acl.private_nacl.id
}