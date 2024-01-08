data "aws_ssm_parameter" "github_webhooks_token" {
  name = "github_webhooks_token"
}

resource "aws_ssm_parameter" "vpn_connection_tunnel1_preshared_key" {
  name   = "/secrets/vpn/preshared_key_tunnel1"
  type   = "SecureString"
  key_id = "alias/aws/ssm"
  value  = var.vpn_connection_tunnel1_preshared_key

  lifecycle {
    ignore_changes = [value]
  }

  tags = var.tags
}