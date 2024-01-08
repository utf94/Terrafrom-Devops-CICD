## Store Datadog API key in AWS Secrets Manager
#variable "dd_api_key" {
#  type        = string
#  description = "Datadog API key"
#}
#
#resource "aws_secretsmanager_secret" "dd_api_key" {
#  name        = "datadog_api_key"
#  description = "Encrypted Datadog API Key"
#}
#
#resource "aws_secretsmanager_secret_version" "dd_api_key" {
#  secret_id     = aws_secretsmanager_secret.dd_api_key.id
#  secret_string = var.dd_api_key
#}
#
## Use the Datadog Forwarder to ship logs from S3 and CloudWatch, as well as observability data from Lambda functions to Datadog. For more information, see https://github.com/DataDog/datadog-serverless-functions/tree/master/aws/logs_monitoring
#resource "aws_cloudformation_stack" "datadog_forwarder" {
#  name         = "datadog-forwarder"
#  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
#  parameters   = {
#    DdApiKeySecretArn  = "arn:aws:secretsmanager:us-east-1:677067263121:secret:datadog_api_key-r5Pvld",
#    DdSite             = "datadoghq.com",
#    FunctionName       = "datadog-forwarder"
#  }
#  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"
#}