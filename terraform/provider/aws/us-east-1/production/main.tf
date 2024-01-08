provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::484097152182:role/automation-terraform-production"
  }
  region = var.region
}

# provider for lambda-edge, lambda deploys have to be us-east-1 for cloudfront even if we switch main provider region
provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::484097152182:role/automation-terraform-production"
  }
  region = var.region
  alias  = "us_east_1"
}

provider "github" {
  token = var.github_token
}

terraform {
  required_version = ">= 0.13"
}

terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "inf-production-terraform-state"
    key            = "terraform.tfstate"
    dynamodb_table = "inf-production-terraform-state-lock"
    role_arn       = "arn:aws:iam::484097152182:role/automation-terraform-production"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0, < 5.0.0"
    }
  }
}

module "terraform_state_backend" {
  source        = "cloudposse/tfstate-backend/aws"
  version       = "1.1.1"
  namespace     = var.namespace
  stage         = var.stage
  name          = "terraform"
  attributes    = ["state"]
  force_destroy = false
}
