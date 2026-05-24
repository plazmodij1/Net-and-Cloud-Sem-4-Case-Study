resource "aws_lb" "main" {
  name               = "${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.alb_public_subnets

  enable_deletion_protection = false

  tags = {
    Environment = "${var.env}"
    Name        = "ALB-Instance"
  }
}

resource "aws_lb_target_group" "main" {
  name        = "${var.env}-lambda-tg"
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_lambda_function.main.arn
  depends_on       = [aws_lambda_permission.alb]
}

resource "aws_lb_target_group" "portal" {
  name        = "${var.env}-portal-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_public
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Environment = "${var.env}"
    Name        = "ALB-Instance"
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.portal.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = aws_acm_certificate.portal_cert.arn

  default_action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn         = aws_cognito_user_pool.portal_users.arn
      user_pool_client_id   = aws_cognito_user_pool_client.alb_client.id
      user_pool_domain      = aws_cognito_user_pool_domain.portal_domain.domain
      session_cookie_name   = "AWSELBAuthSessionCookie"
      session_timeout       = 3600
    }

  }

  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.portal.arn
  }
}