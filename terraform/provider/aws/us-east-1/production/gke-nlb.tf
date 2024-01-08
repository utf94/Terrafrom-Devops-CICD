  module "nlb" {
    source = "cloudposse/nlb/aws"
    # Cloud Posse recommends pinning every module to a specific version
    version = "v0.14.0"
    vpc_id                                          = module.compute_vpc.vpc_id
    subnet_ids                                      = module.compute_subnets.private_subnet_ids
    internal                                        = true
    tcp_enabled                                     = true
    access_logs_enabled                             = false
    cross_zone_load_balancing_enabled               = true
    # idle_timeout                                    = 5
    ip_address_type                                 = "ipv4"
    deletion_protection_enabled                     = false
    target_group_port                               = 80
    target_group_target_type                        = "instance"
  }