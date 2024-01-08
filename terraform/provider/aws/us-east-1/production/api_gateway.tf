#### Custom API Gateway Domain name with DNS record and TLS certificate
resource "aws_api_gateway_domain_name" "api_domain" {
  regional_certificate_arn = module.acm_wildcard.arn
  domain_name              = "api.${var.domain[var.stage]}"
  security_policy          = "TLS_1_2"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}


resource "aws_api_gateway_domain_name" "ws_domain" {
  regional_certificate_arn = module.acm_wildcard.arn
  domain_name              = "ws.${var.domain[var.stage]}"
  security_policy          = "TLS_1_2"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

#### API Gateway configuration

# VPC Link for HTTP API
resource "aws_apigatewayv2_vpc_link" "vpc_link_to_compute_vpc" {
  name               = "compute-vpc-link"
  security_group_ids = [aws_security_group.compute_default_sg.id]
  subnet_ids         = module.compute_subnets.private_subnet_ids

  tags = var.tags
}