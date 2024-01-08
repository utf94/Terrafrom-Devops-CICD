# CICD Default Deployment bucket
resource "aws_s3_bucket" "codebuild_deployment_bucket" {
  bucket = "${var.namespace}-${var.stage}-codebuild-deployment"

  tags = merge(var.tags, {
    Environment = var.stage
  })
}

resource "aws_s3_bucket_ownership_controls" "codebuild_deployment_bucket" {
  bucket = aws_s3_bucket.codebuild_deployment_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "codebuild_deployment_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.codebuild_deployment_bucket]

  bucket = aws_s3_bucket.codebuild_deployment_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "codebuild_deployment_bucket" {
  bucket = aws_s3_bucket.codebuild_deployment_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}


# CodeBuild IAM policy
data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    sid = "BaseAccess"
    actions = [
      "logs:*",
      "lambda:*",
      "tags:*",
      "s3:*",
      "cloudformation:*",
      "cloudfront:*",
      "events:*",
      "sts:*",
      "ec2:*",
      "ecr:*",
      "ecr-public:*",
      "apigateway:*",
      "kms:Describe*",
      "kms:List*",
      "kms:Decrypt*",
      "kms:Encrypt*",
      "iam:GetRole",
      "iam:Tag*",
      "iam:PutRolePolicy",
      "iam:CreateServiceLinkedRole",
      "iam:CreateRole",
      "iam:DeleteRolePolicy",
      "iam:DeleteRole",
      "ssm:GetParameter"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "codebuild_policy" {
  name   = "codebuild-policy"
  policy = data.aws_iam_policy_document.codebuild_policy.json
}