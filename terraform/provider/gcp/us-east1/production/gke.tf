# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                       = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version                      = "27.0.0"
  project_id                   = var.gcp_project
  name                         = "${var.namespace}-${var.stage}-cluster"
  region                       = var.gcp_region
  zones                        = var.gcp_zones
  network                      = module.compute_vpc.network_name
  subnetwork                   = module.compute_vpc.subnets_names[0]
  ip_range_pods                = module.compute_vpc.subnets_secondary_ranges[0][4].range_name
  ip_range_services            = module.compute_vpc.subnets_secondary_ranges[0][5].range_name
  horizontal_pod_autoscaling   = true
  enable_private_endpoint      = false
  enable_private_nodes         = true
  enable_tpu                   = true
  master_global_access_enabled = false
  release_channel              = "REGULAR"
  #  enable_cost_allocation       = true
  # The IP range to use for the hosted master network only, not affecting workloads or services.
  master_ipv4_cidr_block = "10.0.0.0/28"
}