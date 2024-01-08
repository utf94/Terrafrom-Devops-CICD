data "google_secret_manager_secret_version_access" "ipsec_vpn_secret" {
  secret = google_secret_manager_secret.ipsec_vpn_secret.name
}

module "aws_vpn_ha" {
  source     = "terraform-google-modules/vpn/google//modules/vpn_ha"
  project_id = var.gcp_project
  region     = var.gcp_region
  network    = "https://www.googleapis.com/compute/v1/projects/${var.gcp_project}/global/networks/${module.compute_vpc.network_name}"
  name       = "aws-tunnel"
  peer_external_gateway = {
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [
      {
        id         = 0
        ip_address = "34.203.23.15" # AWS Tunnel 1 WAN ip address
      },
      {
        id         = 1
        ip_address = "52.2.56.94" # AWS Tunnel 2 WAN ip address
      }
    ]
  }
  router_asn = 64514
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.64.13"
        asn     = 64512
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.64.14/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = data.google_secret_manager_secret_version_access.ipsec_vpn_secret.secret_data
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.65.13"
        asn     = 64512
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.65.14/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 1
      shared_secret                   = data.google_secret_manager_secret_version_access.ipsec_vpn_secret.secret_data
    }
  }
}