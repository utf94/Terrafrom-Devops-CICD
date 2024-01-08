######################################################################
#                                                                    #
#  Refer to documentation for service's API deployment requirements  #
#                                                                    #
######################################################################

# GKE Alpha Ingress Controller and rules
resource "aws_lb_target_group_attachment" "gke_ingress_alpha" {
  target_group_arn  = aws_lb_target_group.gke_internal_alb_alpha.arn
  target_id         = var.gke_internal_ingress_lb_ip.ingress-alpha
  availability_zone = "all"
  port              = 80
}

# Rules are subject to change
# please validate the GKE workload deployment and refer to documentation how to configure the ingress controller
#

resource "aws_lb_listener_rule" "forward" {
  listener_arn = module.gke_internal_alb.listener_arns[0]
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gke_internal_alb_alpha.arn
  }

  condition {
    host_header {
      values = ["*.${var.domain[var.stage]}"]
    }
  }
}

resource "aws_lb_listener_rule" "cors" {
  listener_arn = module.gke_internal_alb.listener_arns[0]
  priority     = 1

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }

  condition {
    http_request_method {
      values = ["OPTIONS"]
    }
  }
}