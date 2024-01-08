#### Variables ####
variable "compute_vpc_cidr" {
  type    = string
  default = "10.16.0.0/16"
}

### Main VPC Config -- DO NOT MODIFY!!! ###
module "compute_vpc" {
  source                  = "cloudposse/vpc/aws"
  version                 = "2.1.0"
  namespace               = var.namespace
  stage                   = var.stage
  name                    = "compute-vpc"
  ipv4_primary_cidr_block = var.compute_vpc_cidr
  instance_tenancy        = "default"
}

###### Networking ######

### Subnets ###
module "compute_subnets" {
  source               = "cloudposse/dynamic-subnets/aws"
  version              = "2.3.0"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = "compute-network"
  vpc_id               = module.compute_vpc.vpc_id
  igw_id               = [module.compute_vpc.igw_id]
  ipv4_cidr_block      = [module.compute_vpc.vpc_cidr_block]
  nat_gateway_enabled  = false
  nat_instance_enabled = false
}

###### Single instance NAT Gateway ####
resource "aws_eip" "compute_nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "compute_nat_gw" {
  allocation_id = aws_eip.compute_nat_gw_eip.id
  subnet_id     = element(module.compute_subnets.public_subnet_ids, 0)

  tags = {
    "Name" : "compute-vpc-nat"
    "Environment" : var.stage
  }
}

resource "aws_route" "compute_nat_gw_private_default_route" {
  for_each       = toset(module.compute_subnets.private_route_table_ids)
  route_table_id = each.key

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.compute_nat_gw.id
  depends_on             = [aws_nat_gateway.compute_nat_gw]
}

## Security groups ###
resource "aws_security_group" "compute_default_sg" {
  name   = "compute-default-sg"
  vpc_id = module.compute_vpc.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = module.compute_subnets.private_subnet_cidrs
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpn_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name : "compute-default-sg"
  })
}
