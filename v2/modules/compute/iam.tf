# IAM role for the Lambda function to allow basic execution and service access
resource "aws_iam_role" "lambda" {
  name = "${var.env}-lambda-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
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
      Resource = var.db_secret_arn
    }]
  })
}

# Policy allowing the Lambda function to create and write logs in CloudWatch
resource "aws_iam_role_policy" "lambda_logging" {
  name = "${var.env}-lambda-monitor-policy"
  role = aws_iam_role.lambda.id
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

#Execution role for the EKS
resource "aws_aim_role" "ecs_execution_role" {
  name = "${var.env}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Environment = var.env
    Name = "${var.env}-ecs-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role = aws_aim_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#Task role for the EKS
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.env}-ecs-portal-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Environment = var.env
    Name = "${var.env}-ecs-execution-role"
  }
}

#Grant the application access to the DB secret
resource "aws_iam_role_policy" "ecs_task_rds_access" {
  name = "${var.env}-ecs-task-rds-access"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["secretsmanager:GetSecretValue"]
      Resource = var.db_secret_arn
    }]
  })
}