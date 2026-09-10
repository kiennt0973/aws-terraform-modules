resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "this" {
  name                                 = var.app_client_name
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = var.generate_secret
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  callback_urls                        = var.callback_urls
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_cognito_identity_pool" "this" {
  count                            = var.create_identity_pool ? 1 : 0
  identity_pool_name               = "${var.user_pool_name}-identity"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.this.id
    provider_name           = aws_cognito_user_pool.this.endpoint
    server_side_token_check = false
  }
}
