resource "aws_iam_role" "rds_monitoring"{
    name = "${var.dev}-db-monitor-role"
    assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        { 
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
            Service = "monitoring.rds.amazonaws.com"
                }
            }
        ]
    })
}
resource "aws_iam_role" "lambda_logging"{
    name = "${var.dev}-lambda-monitor-role"
    assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{ 
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
            Service = "lambda.amazonaws.com"
            }
        }]
    })
}

resource "aws_iam_role_policy" "lambda_logging" {
    name   = "${var.dev}-lambda-monitor-policy"
    role   = aws_iam_role.lambda-logging.id
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

resource "aws_iam_role_policy_attachment" "lambda_logging"{
    role = aws_iam_role.lambda_logging.name
    policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
    role        = aws_iam_role.rds_monitoring.name
    policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
