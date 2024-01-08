### CICD pipeline

#module "vectors" {
#  #  source    = "cloudposse/cicd/aws"
#  #  version   = "0.20.0"
#
#  source    = "../../modules/terraform-aws-ecs-codepipeline"
#  namespace = var.namespace
#  stage     = var.stage
#  name      = "vectors"
#  enabled   = true
#
#  github_oauth_token    = "github_token"
#  github_webhooks_token = data.aws_ssm_parameter.github_webhooks_token.value
#  repo_owner            = var.github_organization
#  repo_name             = "vectors"
#  branch                = var.github_default_branch
#  webhook_enabled       = true
#
#  poll_source_changes = false
#  buildspec           = "${aws_s3_bucket.codebuild_deployment_bucket.arn}/docker/buildspec/default.yml"
#  build_image         = var.cpu_codebuild_image
#  build_compute_type  = var.cpu_codebuild_type
#  privileged_mode     = true
#  region              = var.region
#  aws_account_id      = var.account_number[var.stage]
#  image_repo_name     = "vectors"
#  image_tag           = "latest"
#
#  environment_variables = [
#    {
#      name  = "GIT_REPO_URL"
#      value = "github.com/${var.github_organization}/vectors"
#      type  = "PLAINTEXT"
#    },
#    {
#      name  = "DEPLOY_BRANCH"
#      value = var.github_default_branch
#      type  = "PLAINTEXT"
#    }
#  ]
#}

#resource "aws_iam_role_policy_attachment" "vectors_build_policy_attachment" {
#  role       = "${var.namespace}-${var.stage}-vectors-build"
#  policy_arn = aws_iam_policy.codebuild_policy.arn
#  depends_on = [module.vectors]
#}

### API Gateway
resource "aws_apigatewayv2_api" "service_vectors" {
  name                         = "vectors"
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = true
  version                      = "1.0"

  cors_configuration {
    allow_credentials = false
    allow_headers = ["*"]
    expose_headers = ["Date", "x-api-id"]
    allow_methods = ["*"]
    allow_origins = ["*"]
    max_age       = 300
  }

  tags                         = var.tags
}

resource "aws_apigatewayv2_integration" "service_vectors" {
  api_id             = aws_apigatewayv2_api.service_vectors.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = module.gke_internal_alb.listener_arns[0]
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpc_link_to_compute_vpc.id

  request_parameters = {
    "overwrite:header.host" = "vectors.${var.domain[var.stage]}"
    "overwrite:path"        = "$request.path"
  }

  depends_on = [aws_apigatewayv2_api.service_vectors]
}

resource "aws_apigatewayv2_integration" "cors_vectors" {
  api_id             = aws_apigatewayv2_api.service_vectors.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = module.gke_internal_alb.listener_arns[0]
  integration_method = "OPTIONS"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpc_link_to_compute_vpc.id

  depends_on = [aws_apigatewayv2_api.service_vectors]
}

resource "aws_apigatewayv2_route" "service_vectors" {
  api_id             = aws_apigatewayv2_api.service_vectors.id
  route_key          = "$default"
  target             = "integrations/${aws_apigatewayv2_integration.service_vectors.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.service_vectors.id
  authorization_type = "JWT"
  depends_on         = [aws_apigatewayv2_api.service_vectors]
}

resource "aws_apigatewayv2_route" "cors_vectors" {
  api_id             = aws_apigatewayv2_api.service_vectors.id
  route_key          = "OPTIONS /{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.cors_vectors.id}"

  depends_on         = [aws_apigatewayv2_api.service_vectors]
}

resource "aws_apigatewayv2_stage" "service_vectors" {
  api_id      = aws_apigatewayv2_api.service_vectors.id
  name        = "$default"
  auto_deploy = true
  depends_on  = [aws_apigatewayv2_api.service_vectors]
}

resource "aws_apigatewayv2_api_mapping" "service_vectors" {
  domain_name     = aws_api_gateway_domain_name.api_domain.id
  api_id          = aws_apigatewayv2_api.service_vectors.id
  stage           = aws_apigatewayv2_stage.service_vectors.id
  api_mapping_key = "vectors"
  depends_on      = [aws_apigatewayv2_api.service_vectors, aws_apigatewayv2_stage.service_vectors]
}

resource "aws_apigatewayv2_authorizer" "service_vectors" {
 name             = "firebase"
 api_id           = aws_apigatewayv2_api.service_vectors.id
 authorizer_type = "JWT"
 identity_sources = ["$request.header.Authorization"]

 jwt_configuration {
   audience = ["infinitia"]
   issuer   = "https://securetoken.google.com/infinitia"
 }
}

### ECR
module "vectors_ecr" {
  source      = "cloudposse/ecr/aws"
  version     = "0.38.0"
  label_order = ["name"]
  name        = "vectors"
}