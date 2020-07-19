# Create VPC
module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.20.0.0/16"
  public_subnet_cidr  = "10.20.0.0/24"
  private_subnet_cidr = "10.20.1.0/24"
  vpc_id              = module.vpc.vpc_id
  aws_region          = var.aws_region
  name_tag            = "plexure_sandbox"
}

# Create Internet Gateway for Public subnet
resource "aws_internet_gateway" "sandbox_igw" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "plexure_sandbox_igw"
  }
}

# Elastic IP for NAT gateway
resource "aws_eip" "nat" {
  vpc = true
}

# Create NAT Gateway for access to the Internet from private subnet
resource "aws_nat_gateway" "sandbox_nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = module.vpc.public_subnet_id
  depends_on    = [aws_internet_gateway.sandbox_igw]
  tags = {
    Name = "plexure_sandbox_nat_gw"
  }
}

# Create Custom Route Tables
resource "aws_route_table" "sandbox_crt_public" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sandbox_igw.id
  }
  tags = {
    Name = "sandbox_crt_public"
  }
}

resource "aws_route_table" "sandbox_crt_private" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.sandbox_nat_gw.id
  }
  tags = {
    Name = "sandbox_crt_private"
  }
}

# Associate CRT and Subnets
resource "aws_route_table_association" "sandbox_crt_public" {
  subnet_id      = module.vpc.public_subnet_id
  route_table_id = aws_route_table.sandbox_crt_public.id
}

resource "aws_route_table_association" "sandbox_crt_private" {
  subnet_id      = module.vpc.private_subnet_id
  route_table_id = aws_route_table.sandbox_crt_private.id
}

# Create a Classic Load Balancer
resource "aws_elb" "plexure_elb" {
  name = "plexure-elb"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  subnets = [module.vpc.public_subnet_id]

  security_groups = [
    aws_security_group.http_allowed.id,
    aws_default_security_group.default.id,
  ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/index.html"
    interval            = 30
  }

  instances                   = [aws_instance.web_server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 30
  tags = {
    Name = "web_server_elb"
  }
}

