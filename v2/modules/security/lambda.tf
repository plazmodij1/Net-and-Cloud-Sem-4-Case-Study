data "archive_file" "email_lambda_zip" {
    type = "zip"
    source_file  = "${path.module}/lambda-script.py"
    output_path = "${path.module}/email_lambda.zip"
}

resource "aws_lambda_function" "soar_brain" {
    filename = data.archive_file.email_lambda_zip.output_path
    function_name = "${var.env}-waf-soar-alerter"
    role = aws_iam_role.lambda_soar_role.arn
    handler = "soar.lambda_handler"
    source_code_hash = data.archive_file.email_lambda_zip.output_base64sha256
    runtime = "python3.10"

    environment {
        variables = {
            SNS_TOPIC_ARN = aws_sns_topic.waf_alerts.arn
        }
    }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.soar_brain.function_name
    principal = "logs.amazonaws.com"
    source_arn = "${aws_cloudwatch_log_group.waf_log_group.arn}:*"
}

