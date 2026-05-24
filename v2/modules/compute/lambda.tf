resource "aws_lambda_function" "main" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.env}-lambda"
  role          = aws_iam_role.lambda.arn
  handler       = "hello.handler"
  runtime       = "nodejs22.x"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 15

  vpc_config {
    security_group_ids = [aws_security_group.lambda.id]
    subnet_ids         = [var.lambda_private_subnet]
  }

  environment {
    variables = {
      DB_HOST    = var.proxy_endpoint
      DB_NAME    = var.db_name
      SECRET_ARN = var.db_secret_arn
    }
  }
  tags = {
    Environment = "${var.env}"
    Name        = "Lambda-instance"
  }
}

resource "aws_lambda_permission" "alb" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.main.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_zip
  output_path = "${path.module}/lambda.zip"
}