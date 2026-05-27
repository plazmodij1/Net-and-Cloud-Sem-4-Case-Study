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
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.env}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = {
    Environment = var.env
    Name = "${var.env}-ecs-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role = aws_iam_role.ecs_execution_role.name
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

#kubernetes iam roles
resource "aws_iam_role" "k8s_node_role" {
  name = "k8s-node-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "ssm_put_policy" {
  name = "ssm-put-policy"
  role = aws_iam_role.k8s_node_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "ssm:PutParameter"
      Resource = aws_ssm_parameter.k3s_kubeconfig.arn
    }]
  })
}

resource "aws_iam_instance_profile" "k8s_profile" {
  name = "k8s-node-profile"
  role = aws_iam_role.k8s_node_role.name
}

##Fargate permission to get SSM parameters
#resource "aws_iam_role_policy" "ecs_ssm_read" {
#  name = "${var.env}-ecs-ssm-read-policy"
#  
#  role = aws_iam_role.ecs_execution_role.name 
#
#  policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Effect = "Allow"
#        Action = [
#          "ssm:GetParameters"
#        ]
#        # This dynamically targets the exact secret
#        Resource = aws_ssm_parameter.k3s_kubeconfig.arn
#      }
#    ]
#  })
#}

resource "aws_iam_policy" "ecs_ssm_read" {
  name        = "${var.env}-ecs-ssm-read-policy"
  description = "Allows the Fargate portal to read the Kubeconfig from SSM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/dev-portal/k3s/kubeconfig"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_ssm_attach" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_ssm_read.arn
}

resource "aws_iam_role_policy" "k8s_ssm_write_policy" {
  name = "k8s-ssm-write-policy"
  
  # 👇 Change this to match the actual name of your EC2 instance's IAM role
  role = aws_iam_role.k8s_node_role.name 

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:PutParameter"
        ]
        # 👇 This restricts the server so it can ONLY overwrite this one specific parameter
        Resource = "arn:aws:ssm:eu-central-1:${data.aws_caller_identity.current.account_id}:parameter/dev-portal/k3s/kubeconfig"
      }
    ]
  })
}

# The Policy for the ECS Agent (Execution Role)
resource "aws_iam_policy" "ecs_execution_ssm_read" {
  name = "${var.env}-ecs-exec-ssm-policy"
  description = " Allow ECS agent to pull secrets from SSM during boot"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/dev-portal/k3s/kubeconfig"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_ssm_attach" {
  role       = aws_iam_role.ecs_execution_role.name 
  policy_arn = aws_iam_policy.ecs_execution_ssm_read.arn
}