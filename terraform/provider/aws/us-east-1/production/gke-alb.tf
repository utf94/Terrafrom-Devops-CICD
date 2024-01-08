module "gke_internal_alb" {
  source  = "cloudposse/alb/aws"
  version = "1.9.0"

  namespace = var.namespace
  stage     = var.stage
  name      = "gke-internal-alb"

  vpc_id                            = module.compute_vpc.vpc_id
  security_group_ids                = [aws_security_group.compute_default_sg.id]
  subnet_ids                        = module.compute_subnets.private_subnet_ids
  internal                          = true
  http_enabled                      = true
  http_redirect                     = false
  http_ingress_prefix_list_ids      = ["pl-3b927c52"]
  http_ingress_cidr_blocks          = [module.compute_vpc.vpc_cidr_block]
  default_target_group_enabled      = false
  access_logs_enabled               = false
  cross_zone_load_balancing_enabled = var.cross_zone_load_balancing_enabled
  http2_enabled                     = true
  idle_timeout                      = 60
  ip_address_type                   = "ipv4"
  deletion_protection_enabled       = true

  listener_http_fixed_response = {
    content_type = "text/plain"
    message_body = "Access denied"
    status_code  = "403"
  }

  tags = var.tags
}

resource "aws_lb_target_group" "gke_internal_alb_alpha" {
  name            = "${var.namespace}-${var.stage}-gke-alb-alpha"
  port            = 80
  protocol        = "HTTP"
  target_type     = "ip"
  ip_address_type = "ipv4"
  vpc_id          = module.compute_vpc.vpc_id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-404"
  }
  tags = var.tags
}