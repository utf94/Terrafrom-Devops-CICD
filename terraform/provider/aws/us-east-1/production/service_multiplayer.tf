

resource "aws_ecs_cluster" "default" {
  name = "multiplayer_cluster"
  tags = null
}

module "container_definition" {
  source = "cloudposse/ecs-container-definition/aws"
  container_name               = "w1"
  container_image              = "zerefdragoneel/game:w13"
  container_memory             = 32768
#   container_memory_reservation = var.container_memory_reservation
  container_cpu                = "16384"
#   essential                    = var.container_essential
  readonly_root_filesystem     = false
  port_mappings                = [
        {
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
        },
        {
            containerPort = 443
            hostPort      = 443
            protocol      = "udp"
        }
    ]
}


module "ecs_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.4.0"

  name       = "ECS-terraform-policy"
  attributes = ["test"]

  iam_policy_enabled = true
  description        = "ECS-terraform-policy"

  iam_policy_statements = [
    {
      sid        = "Terraform"
      effect     = "Allow"
      actions    = ["none:null"]
      resources  = ["*"]
      conditions = []
    }
  ]
}


module "ecs_alb_service_task" {
  source = "cloudposse/ecs-alb-service-task/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"
  namespace                          = "multiplayer-13"
  alb_security_group                 = module.compute_vpc.vpc_default_security_group_id
  name                               = "world1"
  container_definition_json          = module.container_definition.json_map_encoded_list
  ecs_cluster_arn                    = aws_ecs_cluster.default.arn
  launch_type                        = "FARGATE"
  vpc_id                             = module.compute_vpc.vpc_id
  security_group_ids                 = [module.compute_vpc.vpc_default_security_group_id]
  subnet_ids                         = module.compute_subnets.public_subnet_ids
  network_mode                       = "awsvpc"
  assign_public_ip                   = true
  deployment_controller_type         = "ECS"
  desired_count                      = "1"
  task_memory                        = 32768
  task_cpu                           = "16384"
  redeploy_on_apply                  = true
  task_policy_arns                   = [module.ecs_policy.policy_arn]
  task_exec_policy_arns_map          = { test = module.ecs_policy.policy_arn }
  
  depends_on = [ module.ecs_policy ]
}