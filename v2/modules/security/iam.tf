resource "aws_iam_role" "lambda_soar_role" {
    name = "${var.env}-waf-soar-lambda-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Action = "sts:AssumeRole",
            Effect = "Allow", 
            Principal = { Service = "lambda.amazonaws.com"}
        }]
    })
}

resource "aws_iam_role_policy" "lambda_sns_policy" {
    name = "${var.env}lambda-sns-policy"
    role = aws_iam_role.lambda_soar_role.id
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
                Resource = "arn:aws:logs:*:*:*"
            },
            {
                Effect = "Allow",
                Action = "sns:Publish",
                Resource = aws_sns_topic.waf_alerts.arn
            }
        ]
    }) 
}