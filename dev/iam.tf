resource "aws_iam_role" "rds_monitoring"{
    name = "${var.dev}-db-monitor-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{ 
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = { Service = "monitoring.rds.amazonaws.com" }
        }]
    })
}

resource "aws_iam_role" "rds_proxy" {
    name = "${var.dev}-rds-proxy-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{ 
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = { Service = "rds.amazonaws.com" }
        }]
    })
}

resource "aws_iam_role" "lambda"{
    name = "${var.dev}-lambda-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{ 
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = { Service = "lambda.amazonaws.com" }
        }]
    })
}

resource "aws_iam_role" "ecs_execution" {
    name = "${var.dev}-ecs-execution-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {Service = "ecs-tasks.amazonaws.com"}
        }]
    })
}

resource "aws_iam_role" "ecs_task" {
    name = "${var.dev}-ecs-task-role"
    assume_role_policy = jsonencode({
        "Version" = "2012-10-17"
        "Statement" = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {Service = "ecs-tasks.amazonaws.com"}
        }]
    })
}

resource "aws_iam_role_policy" "lambda_secrets" {
    name = "${var.dev}-lambda-secrets-policy"
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

resource "aws_iam_role_policy" "rds-proxy" {
    name   = "${var.dev}-rds-proxy-policy"
    role   = aws_iam_role.rds_proxy.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = ["secretsmanager:GetSecretValue"]
            Resource = aws_secretsmanager_secret.db_cred.arn
        }]
    })          
}

resource "aws_iam_role_policy" "lambda_logging" {
    name   = "${var.dev}-lambda-monitor-policy"
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


resource "aws_iam_role_policy_attachment" "rds_monitoring" {
    role        = aws_iam_role.rds_monitoring.name
    policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
    role       = aws_iam_role.lambda.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
    role        = aws_iam_role.ecs_execution.name
    policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
    role        = aws_iam_role.ecs_task.name
    policy_arn  = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
