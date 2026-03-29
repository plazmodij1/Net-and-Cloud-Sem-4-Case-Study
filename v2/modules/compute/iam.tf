# IAM role for the Lambda function to allow basic execution and service access
resource "aws_iam_role" "lambda"{
    name = "${var.env}-lambda-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{ 
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = { Service = "lambda.amazonaws.com" }
        }]
    })
}

# Policy allowing the Lambda function to retrieve database credentials from Secrets Manager
resource "aws_iam_role_policy" "lambda_secrets" {
    name = "${var.env}-lambda-secrets-policy"
    role = aws_iam_role.lambda.id 
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect   = "Allow",
            Action   = ["secretsmanager:GetSecretValue"],
            Resource = aws_secretsmanager_secret.db_cred.arn
        }]
    })
}

# Policy allowing the Lambda function to create and write logs in CloudWatch
resource "aws_iam_role_policy" "lambda_logging" {
    name   = "${var.env}-lambda-monitor-policy"
    role   = aws_iam_role.lambda.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Sid    = "Statement1"
            Effect = "Allow"
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        Resource = "*"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
    role       = aws_iam_role.lambda.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}