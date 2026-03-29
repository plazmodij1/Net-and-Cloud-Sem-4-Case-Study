resource "aws_lambda_function" "main"{
    filename        = "./hello.zip"
    function_name   = "${var.env}-lambda"
    role            = aws_iam_role.lambda.arn
    handler         = "hello.handler"
    runtime         = "nodejs22.x"

    source_code_hash    = filebase64sha256("./hello.zip")
    timeout             = 15

    vpc_config {
        security_group_ids  = [aws_security_group.lambda.id]
        subnet_ids          = var.lambda_private_subnet
    }

    environment {
        variables = {
            DB_HOST = var.proxy_endpoint
            DB_NAME = var.db_name
            SECRET_ARN = aws_secretsmanager_secret.db_cred.arn
        }
    }
    tags = {
        Environment = "${var.env}"
        Name        = "Lambda-instance"
    }
}

resource "aws_lambda_permission" "alb" {
    statement_id = "AllowExecutionFromALB"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.main.function_name
    principal = "elasticloadbalancing.amazonaws.com"
    source_arn = aws_lb_target_group.main.arn
}