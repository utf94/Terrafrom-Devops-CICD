variable "gcp_region" {
  type    = string
  default = "us-east1"
}

variable "gcp_zones" {
  type = list(string)
  default = [
    "us-east1-b",
    "us-east1-c",
    "us-east1-d"
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

variable "gcp_project" {
  type    = string
  default = "infinitia"
}

variable "labels" {
  type = map(string)
  default = {
    Managed = "terraform"
  }
}

variable "ipsec_vpn_secret" {
  type = string
}

variable "aws_compute_vpc_cidr" {
  type    = string
  default = "10.16.0.0/16"
}