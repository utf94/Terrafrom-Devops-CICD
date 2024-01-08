resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
  vpc_id            = module.compute_vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = module.compute_subnets.private_route_table_ids

  tags = var.tags
}

resource "aws_vpc_endpoint" "ecr_dkr_vpc_endpoint" {
  vpc_id            = module.compute_vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.compute_default_sg.id,
  ]

  private_dns_enabled = true

  tags = var.tags
}

resource "aws_vpc_endpoint" "ecr_api_vpc_endpoint" {
  vpc_id            = module.compute_vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.compute_default_sg.id,
  ]

  private_dns_enabled = true

  tags = var.tags
}