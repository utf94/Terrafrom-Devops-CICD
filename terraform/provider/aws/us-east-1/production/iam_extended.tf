### Identity providers
## Google SAML for AWS VPN
#resource "aws_iam_saml_provider" "google_saml_vpn_idp" {
#  name                   = "Google-saml-vpn-idp"
#  saml_metadata_document = file("../../resources/GoogleIDPMetadata.xml")
#  tags                   = var.tags
#}

module "requester_vpc_peering_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.4.0"
  name    = "requester-vpc-peering-policy"

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

resource "aws_iam_role" "requester_cross_account_vpc_peering" {
  name               = "requester-cross-account-vpc-peering"
  assume_role_policy = data.aws_iam_policy_document.requester_cross_account_vpc_peering.json

  inline_policy {
    name   = "requester-vpc-peering-policy"
    policy = module.requester_vpc_peering_policy.json
  }
}
