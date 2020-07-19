# Create VPC
resource "aws_vpc" "sandbox" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = "true"    # gives you an internal domain name
  enable_dns_hostnames = "true"    # gives you an internal host name
  instance_tenancy     = "default" # dedicated is too expensive :)
  tags = {
    Name = "${var.name_tag}"
  }
}

# Create two subnets in the same AZ
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.sandbox.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = "true"               # should be assigned a public IP address
  availability_zone       = "${var.aws_region}a" #  for ex.: "us-east-1a"
  tags = {
    Name = "public_${var.name_tag}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.sandbox.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}a" # "us-east-1a"
  tags = {
    Name = "private_${var.name_tag}"
  }
}
