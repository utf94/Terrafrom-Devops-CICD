### AWS related variables
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "account_number" {
  type = map(string)
  default = {
    production = "484097152182"
  }
}

variable "cpu_codebuild_image" {
  type    = string
  default = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "cpu_codebuild_type" {
  type    = string
  default = "BUILD_GENERAL1_SMALL"
}

variable "availability_zones" {
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
}

variable "namespace" {
  type    = string
  default = "inf"
}

variable "stage" {
  type    = string
  default = "production"
}

variable "zone_id" {
  type    = string
  default = ""
}

## Github
variable "github_organization" {
  type    = string
  default = "webaverse-studios"
}

variable "github_token" {
  type        = string
  description = "Token for github oauth"
}

variable "github_webhook_token" {
  type        = string
  description = "Token for github oauth"
}

variable "github_default_branch" {
  type    = string
  default = "main"
}

variable "git_url" {
  type    = string
  default = "github.com/webaverse-studios"
}

# Regular variables

variable "domain" {
  type = map(string)
  default = {
    production = "webaverse.studio"
  }
}

variable "tags" {
  type = map(string)
  default = {
    Managed = "terraform"
  }
}

variable "vpn_cidr" {
  type    = string
  default = "10.250.0.0/16"
}

variable "gcp_cidr" {
  type    = string
  default = ""
}

variable "vpc_id_compute" {
  type = map(string)
  default = {
    production = "vpc-050a906572d45a8a8",
    vpn        = "vpc-028d48496b38c78aa"
  }
}

variable "vpc_id_data" {
  type = map(string)
  default = {
    dev        = "",
    staging    = "",
    production = ""
  }
}

variable "lambda_provisioned_concurrency" {
  type    = number
  default = 1
}


### Set of secrets set via SSM
variable "vpn_connection_tunnel1_preshared_key" {
  type = string
}

## End of SSM parameters

variable "accepter_cross_account_vpc_peering" {
  type = map(string)
  default = {
    prod = "arn:aws:iam::677067263121:role/accepter-cross-account-vpc-peering"
  }
}

variable "cross_zone_load_balancing_enabled" {
  type    = bool
  default = true
}

variable "gke_internal_ingress_lb_ip" {
  type = map(string)
  default = {
    ingress-alpha   = "10.24.0.9"
    ingress-beta    = ""
    ingress-gamma   = ""
    ingress-delta   = ""
    ingress-epsilon = ""
    ingress-zeta    = ""
    ingress-eta     = ""
    ingress-theta   = ""
    ingress-iota    = ""
    ingress-kappa   = ""
  }
}

variable "auth0_authorizer" {
  type = object({
    name             = string
    authorizer_type  = string
    identity_sources = list(string)
    jwt_configuration = object({
      issuer   = string
      audience = list(string)
    })
  })
  default = {
    name             = "auth0"
    authorizer_type  = "JWT"
    identity_sources = ["$request.header.Authorization"]
    jwt_configuration = {
      issuer   = ""
      audience = [""]
    }
  }
}

variable "datadog_delegation_id" {
  type    = string
  default = "c5bf0896f3b94aca911f25e6490f6c2b"
}