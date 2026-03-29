resource "aws_lb" "main" {
    name                = "${var.env}-alb"
    internal            = false
    load_balancer_type  = "application"
    security_groups     = [aws_security_group.alb.id]
    subnets             = var.alb_public_subnets
    
    enable_deletion_protection = false

    tags = {
        Environment = "${var.env}"
        Name        = "ALB-Instance"
    }
}

resource "aws_lb_target_group" "main" {
    name = "${var.env}-lambda-tg"
    target_type = "lambda"
}

resource "aws_lb_listener" "main" {
    load_balancer_arn    = aws_lb.main.arn
    port = "80" 
    protocol = "HTTP"   
    
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.main.arn
    }
}

resource "aws_lb_target_group_attachment" "main" {
    target_group_arn = aws_lb_target_group.main.arn
    target_id = aws_lambda_function.main.arn
    depends_on = [aws_lambda_permission.alb]
}
