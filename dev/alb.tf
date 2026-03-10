resource "aws_lb_target_group" "main" {
    name = "${var.dev}-lambda-tg"
    target_type = "lambda"
}

resource "aws_lambda_permission" "alb" {
    statement_id = "AllowExecutionFromALB"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.main.function_name
    principal = "elasticloadbalancing.amazonaws.com"
    source_arn = aws_lb_target_group.main.arn
}

resource "aws_lb_target_group_attachment" "main" {
    target_group_arn = aws_lb_target_group.main.arn
    target_id = aws_lambda_function.main.arn
    depends_on = [aws_lambda_permission.alb]
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
