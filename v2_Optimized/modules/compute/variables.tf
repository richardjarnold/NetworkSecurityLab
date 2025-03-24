variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}

variable "public_sg_id" {
  description = "Security group ID for the public instance"
  type        = string
}

variable "private_sg_id" {
  description = "Security group ID for the private instance"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to instances"
  type        = map(string)
}