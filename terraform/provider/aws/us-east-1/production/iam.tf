### Serverless policy for lambdas
## The base policy shared among all lambdas
data "aws_iam_policy_document" "base_policy" {
  statement {
    sid = "BaseAccess"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "tags:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

# Backend lambda policies/roles
data "aws_iam_policy_document" "backend_server_policy" {
  statement {
    sid = "IAMAccess"
    actions = [
      "iam:AssumeRole",
      "iam:PassRole",
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
}

module "backend_server_lambda_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.18.0"

  enabled          = true
  namespace        = var.namespace
  stage            = var.stage
  name             = "backend-server-lambda"
  role_description = "IAM role with permissions to perform actions for Lambdas"
  principals = {
    Service = [
      "lambda.amazonaws.com"
    ]
  }
  policy_documents = [
    data.aws_iam_policy_document.base_policy.json,
    data.aws_iam_policy_document.backend_server_policy.json
  ]
}


### VPC Peering
data "aws_iam_policy_document" "requester_cross_account_vpc_peering" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_number["production"]}:root"]
    }
  }
}

module "accepter_vpc_peering_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.4.0"
  name    = "accepter-vpc-peering-policy"

  iam_policy_statements = {
    RTModify = {
      effect     = "Allow"
      actions    = ["ec2:CreateRoute", "ec2:DeleteRoute"]
      resources  = ["arn:aws:ec2:*:${var.account_number[var.stage]}:route-table/*"]
      conditions = []
    }
    DescribePeering = {
      effect = "Allow"
      actions = [
        "ec2:DescribeVpcPeeringConnections",
        "ec2:DescribeVpcs",
        "ec2:ModifyVpcPeeringConnectionOptions",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeRouteTables"
      ]
      resources  = ["*"]
      conditions = []
    }
    ControlPeering = {
      effect = "Allow"
      actions = [
        "ec2:AcceptVpcPeeringConnection",
        "ec2:DeleteVpcPeeringConnection",
        "ec2:CreateVpcPeeringConnection",
        "ec2:RejectVpcPeeringConnection"
      ]
      resources = [
        "arn:aws:ec2:*:${var.account_number[var.stage]}:vpc-peering-connection/*",
      "arn:aws:ec2:*:${var.account_number[var.stage]}:vpc/*"]
      conditions = []
    }
    EC2Tags = {
      effect = "Allow"
      actions = [
        "ec2:DeleteTags",
        "ec2:CreateTags"
      ]
      resources  = ["arn:aws:ec2:*:${var.account_number[var.stage]}:vpc-peering-connection/*"]
      conditions = []
    }
  }
}

resource "aws_iam_role" "accepter_cross_account_vpc_peering" {
  name               = "accepter-cross-account-vpc-peering"
  assume_role_policy = data.aws_iam_policy_document.requester_cross_account_vpc_peering.json

  inline_policy {
    name   = "vpc-peering-policy"
    policy = module.accepter_vpc_peering_policy.json
  }
}

# ECR Private Repo access role
data "aws_iam_policy_document" "ecr_private_repo_policy" {
  statement {
    sid = "ReadOnlyAccess"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribePullThroughCacheRules",
      "ecr:DescribeRegistry",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRegistryPolicy",
      "ecr:ListImages"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

module "ecr_private_repo_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.18.0"

  enabled          = true
  namespace        = var.namespace
  stage            = var.stage
  name             = "ecr-private-repo-access"
  role_description = "IAM role with read only permissions to perform actions on ECR private repos"
  principals = {
    Federated = ["accounts.google.com"]
  }
  assume_role_actions = ["sts:AssumeRoleWithWebIdentity"]
  assume_role_conditions = [
    {
      test     = "StringEquals"
      variable = "accounts.google.com:aud"
      values   = ["107025167738094697696"]
    }
  ]
  policy_documents = [
    data.aws_iam_policy_document.ecr_private_repo_policy.json
  ]
}

### ECR User for GKE ECR Access
module "ecr_gke_user" {
  source      = "cloudposse/iam-system-user/aws"
  version     = "1.2.0"
  namespace   = var.namespace
  stage       = var.stage
  name        = "ecr-gke-user"
  ssm_enabled = true
  inline_policies_map = {
    ecr = data.aws_iam_policy_document.ecr_private_repo_policy.json
  }
}

### DataDog IAM Policy and Role
data "aws_iam_policy_document" "DatadogIntegrationPolicy" {
  statement {
    sid = "DatadogIntegrationPolicy"
    actions = [
      "apigateway:GET",
      "autoscaling:Describe*",
      "backup:List*",
      "budgets:ViewBudget",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListDistributions",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:LookupEvents",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "codedeploy:List*",
      "codedeploy:BatchGet*",
      "directconnect:Describe*",
      "dynamodb:List*",
      "dynamodb:Describe*",
      "ec2:Describe*",
      "ecs:Describe*",
      "ecs:List*",
      "elasticache:Describe*",
      "elasticache:List*",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeTags",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticloadbalancing:Describe*",
      "elasticmapreduce:List*",
      "elasticmapreduce:Describe*",
      "es:ListTags",
      "es:ListDomainNames",
      "es:DescribeElasticsearchDomains",
      "events:CreateEventBus",
      "fsx:DescribeFileSystems",
      "fsx:ListTagsForResource",
      "health:DescribeEvents",
      "health:DescribeEventDetails",
      "health:DescribeAffectedEntities",
      "kinesis:List*",
      "kinesis:Describe*",
      "lambda:GetPolicy",
      "lambda:List*",
      "logs:DeleteSubscriptionFilter",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeSubscriptionFilters",
      "logs:FilterLogEvents",
      "logs:PutSubscriptionFilter",
      "logs:TestMetricFilter",
      "organizations:Describe*",
      "organizations:List*",
      "rds:Describe*",
      "rds:List*",
      "redshift:DescribeClusters",
      "redshift:DescribeLoggingStatus",
      "route53:List*",
      "s3:GetBucketLogging",
      "s3:GetBucketLocation",
      "s3:GetBucketNotification",
      "s3:GetBucketTagging",
      "s3:ListAllMyBuckets",
      "s3:PutBucketNotification",
      "ses:Get*",
      "sns:List*",
      "sns:Publish",
      "sqs:ListQueues",
      "states:ListStateMachines",
      "states:DescribeStateMachine",
      "support:DescribeTrustedAdvisor*",
      "support:RefreshTrustedAdvisorCheck",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
      "xray:BatchGetTraces",
      "xray:GetTraceSummaries"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

module "datadog_integration_role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.18.0"

  enabled             = true
  namespace           = var.namespace
  stage               = var.stage
  name                = "datadog-integration-role"
  role_description    = "IAM role for DD integration"
  assume_role_actions = ["sts:AssumeRole"]
  principals = {
    AWS = [
      "464622532012"
    ]
  }
  assume_role_conditions = [
    {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.datadog_delegation_id]
    }
  ]
  policy_documents = [data.aws_iam_policy_document.DatadogIntegrationPolicy.json]
}