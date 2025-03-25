#Define Required Provider
terraform {
  required_providers {
    aws = {
      version = "~> 5.92.0" # Version Pin
    }
  }
}

#Define Provider
provider "aws" {
  region = var.region
}

#Deploy network configurations
module "network" {
  source                    = "../../modules/network"
  vpc_cidr                  = var.vpc_cidr
  public_subnet_cidr        = var.public_subnet_cidr
  private_subnet_cidr       = var.private_subnet_cidr
  public_availability_zone  = var.public_availability_zone
  private_availability_zone = var.private_availability_zone
  tags                      = var.tags
}

#Deploy key for ssh
resource "aws_key_pair" "lab_key" {
  key_name   = "lab-key"
  public_key = file("${path.module}/keys/lab-key.pub")

  tags = {
    Name = "Lab-Key-Pair"
  }
}

#Deploy ec2
module "compute" {
  source = "../../modules/compute"

  ami_id            = "ami-04aa00acb1165b32a"
  instance_type     = "t2.micro"
  public_subnet_id  = module.network.public_subnet_id
  private_subnet_id = module.network.private_subnet_id
  public_sg_id      = module.network.public_sg_id
  private_sg_id     = module.network.private_sg_id
  key_name          = aws_key_pair.lab_key.key_name
  tags              = var.tags
}