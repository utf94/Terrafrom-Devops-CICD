module "acm_wildcard" {
  source    = "cloudposse/acm-request-certificate/aws"
  version   = "0.16.3"
  namespace = var.namespace
  stage     = var.stage

  name                              = "wildcard.${var.domain[var.stage]}"
  domain_name                       = var.domain[var.stage]
  process_domain_validation_options = false
  ttl                               = 300
  subject_alternative_names         = ["*.${var.domain[var.stage]}"]
}