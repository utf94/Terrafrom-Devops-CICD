#### Variables ####
locals {
  vpc_cidr       = "10.24.0.0/16"
  subnet-01      = "10.25.0.0/20"
  subnet-02      = "10.25.16.0/20"
  subnet-03      = "10.25.32.0/20"
  subnet-04      = "10.25.48.0/20"
  subnet-ingress = "10.25.64.0/20"
  subnet-pods    = "10.26.0.0/18"
  subnet-svc     = "10.27.0.0/21"
}

module "compute_vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.3.0"

  project_id   = var.gcp_project
  network_name = "${var.namespace}-${var.stage}-compute-vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${var.namespace}-${var.stage}-compute-network-private"
      subnet_ip             = local.vpc_cidr
      subnet_region         = var.gcp_region
      subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
    inf-production-compute-network-private = [
      {
        range_name    = "${var.namespace}-${var.stage}-subnet-01"
        ip_cidr_range = local.subnet-01
      },
      {
        range_name    = "${var.namespace}-${var.stage}-subnet-02"
        ip_cidr_range = local.subnet-02
      },
      {
        range_name    = "${var.namespace}-${var.stage}-subnet-03"
        ip_cidr_range = local.subnet-03
      },
      {
        range_name    = "${var.namespace}-${var.stage}-subnet-04"
        ip_cidr_range = local.subnet-04
      },
      {
        range_name    = "${var.namespace}-${var.stage}-subnet-pods"
        ip_cidr_range = local.subnet-pods
      },
      {
        range_name    = "${var.namespace}-${var.stage}-subnet-svc"
        ip_cidr_range = local.subnet-svc
      }
    ]
  }

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
}

resource "google_compute_subnetwork" "gke_ingress_subnet" {
  provider = google-beta

  name          = "${var.namespace}-${var.stage}-ingress"
  ip_cidr_range = local.subnet-ingress
  region        = var.gcp_region
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = module.compute_vpc.network_name
}

module "compute_cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 5.0"

  name    = "${var.namespace}-${var.stage}-compute-network-router"
  project = var.gcp_project
  region  = var.gcp_region
  network = module.compute_vpc.network_name
  nats = [
    {
      name                               = "egress-nat"
      nat_ip_allocate_option             = "AUTO_ONLY"
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    }
  ]
}

module "vpc_firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.gcp_project
  network_name = module.compute_vpc.network_name

  rules = [{
    name                    = "allow-aws-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = 100
    ranges                  = [var.aws_compute_vpc_cidr]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "all"
    }]
    deny = []
  }]
}

module "gke_ingress_firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.gcp_project
  network_name = module.compute_vpc.network_name

  rules = [{
    name                    = "allow-gke-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = 101
    ranges                  = [google_compute_subnetwork.gke_ingress_subnet.ip_cidr_range]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "all"
    }]
    deny = []
  }]
}