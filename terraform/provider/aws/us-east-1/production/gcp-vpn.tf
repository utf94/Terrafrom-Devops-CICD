data "aws_ssm_parameter" "vpn_connection_tunnel1_preshared_key" {
  name            = "/secrets/vpn/preshared_key_tunnel1"
  with_decryption = true
}

module "gcp_vpn_connection" {
  source                                    = "cloudposse/vpn-connection/aws"
  version                                   = "0.9.0"
  namespace                                 = var.namespace
  stage                                     = var.stage
  name                                      = "gcp-tunnel"
  vpc_id                                    = module.compute_vpc.vpc_id
  vpn_gateway_amazon_side_asn               = 64512
  customer_gateway_bgp_asn                  = 64514
  customer_gateway_ip_address               = "35.242.8.202"
  route_table_ids                           = module.compute_subnets.private_route_table_ids
  vpn_connection_static_routes_only         = false
  vpn_connection_static_routes_destinations = ["10.24.0.0/16"]
  # Tunnel 1
  vpn_connection_tunnel1_inside_cidr                  = "169.254.64.12/30"
  vpn_connection_tunnel1_dpd_timeout_action           = "restart"
  vpn_connection_tunnel1_ike_versions                 = ["ikev2"]
  vpn_connection_tunnel1_phase1_dh_group_numbers      = [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  vpn_connection_tunnel1_phase2_dh_group_numbers      = [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  vpn_connection_tunnel1_phase1_integrity_algorithms  = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
  vpn_connection_tunnel1_phase2_integrity_algorithms  = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
  vpn_connection_tunnel1_phase1_encryption_algorithms = ["AES128-GCM-16", "AES256-GCM-16"]
  vpn_connection_tunnel1_phase2_encryption_algorithms = ["AES128-GCM-16", "AES256-GCM-16"]
  vpn_connection_tunnel1_preshared_key                = aws_ssm_parameter.vpn_connection_tunnel1_preshared_key.value
  vpn_connection_tunnel1_startup_action               = "start"
  # Tunnel 2
  vpn_connection_tunnel2_inside_cidr                  = "169.254.65.12/30"
  vpn_connection_tunnel2_dpd_timeout_action           = "restart"
  vpn_connection_tunnel2_ike_versions                 = ["ikev2"]
  vpn_connection_tunnel2_phase1_dh_group_numbers      = [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  vpn_connection_tunnel2_phase2_dh_group_numbers      = [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  vpn_connection_tunnel2_phase1_integrity_algorithms  = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
  vpn_connection_tunnel2_phase2_integrity_algorithms  = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
  vpn_connection_tunnel2_phase1_encryption_algorithms = ["AES128-GCM-16", "AES256-GCM-16"]
  vpn_connection_tunnel2_phase2_encryption_algorithms = ["AES128-GCM-16", "AES256-GCM-16"]
  vpn_connection_tunnel2_preshared_key                = aws_ssm_parameter.vpn_connection_tunnel1_preshared_key.value
  vpn_connection_tunnel2_startup_action               = "start"
  tags                                                = var.tags
}