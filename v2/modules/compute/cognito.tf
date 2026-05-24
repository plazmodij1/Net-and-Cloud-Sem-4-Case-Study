resource "aws_cognito_user_pool" "portal_users" {
  name = "${var.env}-portal-users"

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length = 5
    require_lowercase = true
    require_numbers = true
    require_symbols = true
    require_uppercase = false
  }

  tags = {
  Environment = var.env
  Name = "${var.env}-portal-users"
  }
}

resource "aws_cognito_user_pool_domain" "portal_domain" {
  domain = "${var.env}-portal-auth-marko-5871923"
  user_pool_id = aws_cognito_user_pool.portal_users.id
}

resource "aws_cognito_user_pool_client" "alb_client" {
  name = "${var.env}-alb-client"
  user_pool_id = aws_cognito_user_pool.portal_users.id
  generate_secret = aws_lb_target_group.main
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO"]

  callback_urls = [
    "https://${aws_lb.main.dns_name}/oauth2/idpresponse"
  ]
}

resource "aws_cognito_user_group" "admin_group" {
  name = "HR-Admins"
  user_pool_id = aws_cognito_user_pool.portal_users.id
  description = "Administrators with full access to employee lifecycle automation"
  precedence = 1
}

resource "aws_cognito_user_group" "employee_group" {
  name = "Employee"
  user_pool_id = aws_cognito_user_pool.portal_users.id
  description  = "Standard users with basic self-service portal access"
  precedence   = 2
}