resource "aws_ecs_cluster" "main" {
    name = "${var.env}-fargate-cluster"

    setting {
      name      = "containerInsights"
      value     = "enabled"
    }

    tags = {
        Environment = var.env
        Name        = "${var.env}-ecs-execution-role"
  }
}

resource "aws_ecs_task_definition" "portal" {
    family                      = "${var.env}-self-service-portal"
    network_mode                = "awsvpc"
    requires_compatibilities    = ["FARGATE"]

    cpu                         = "256"
    memory                      = "512"

    execution_role_arn          = aws_iam_role.ecs_execution_role.arn
    task_role_arn               = aws_iam_role.ecs_task_role.arn

    container_definitions = jsonencode([{
        name        = "portal-container"
        image       = aws_ecr_repository.portal_repo.repository_url ##################################################################################################################
        essential   = true

        portMappings = [{
            containerPort   = 8080
            hostPort        = 8080
            protocol        = "tcp"
        }]

        secrets = [
            {
                name = "KUBECONFIG_B64"
                valueForm = aws_ssm_parameter.k3s_kubeconfig.arn
            }
        ]

        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group"         = "/ecs/${var.env}-portal"
                "awslogs-region"        = var.region
                "awslogs-stream-prefix" = "ecs"
            }
        }
    }])

    tags = {
        Environment = var.env
        Name        = "${var.env}-portal-task"
    }
}

resource "aws_cloudwatch_log_group" "portal_logs" {
    name = "/ecs/${var.env}-portal"
    retention_in_days = 7

    tags = {
        Environment = var.env
        Name        = "${var.env}-portal-task"
    }
}

resource "aws_ecs_service" "portal" {
  name              = "${var.env}-portal-service"
  cluster           = aws_ecs_cluster.main.id
  task_definition   = aws_ecs_task_definition.portal.arn
  desired_count     = 2
  launch_type       = "FARGATE"
  
  network_configuration {
    subnets             = var.eks-portal-subnets
    security_groups     = [aws_security_group.ecs_portal.id]
    assign_public_ip    = false
  }

  load_balancer {
    target_group_arn    = aws_lb_target_group.portal.arn
    container_name      = "portal-container"
    container_port      = 8080
  }

    wait_for_steady_state = false

  tags = {
    Environment = var.env
    Name        = "${var.env}-portal-task"
  }
}

#ECS Standalone Task to fill the database tables
resource "aws_ecs_task_definition" "db_init" {
    family = "${var.env}-db-init-task"
    network_mode                = "awsvpc"
    requires_compatibilities    = ["FARGATE"]

    cpu                         = "256"
    memory                      = "512"

    execution_role_arn          = aws_iam_role.ecs_execution_role.arn
    task_role_arn               = aws_iam_role.ecs_task_role.arn

    container_definitions = jsonencode([{
        name      = "db-initializer"
        image     = "alpine:3.18"
        essential = true

        environment = [
            {name = "DB_HOST", value = var.proxy_endpoint },
            {name = "DB_PORT", value = "3306"}
        ]

        #Script to execute fill the DB tables
        command = ["/bin/sh", "-c"]
        args = [
        <<-EOT
        echo "Installing dependencies..."
        apk add --no-cache aws-cli mysql-client jq

        echo "Fetching database credentials securely via IAM Task Role..."
        SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id $SECRET_ID --query SecretString --output text)
        
        DB_USER=$(echo $SECRET_JSON | jq -r '.username')
        DB_PASS=$(echo $SECRET_JSON | jq -r '.password')
        
        echo "Connecting to RDS Proxy and creating Employee table..."
        mysql -h $DB_HOST -u $DB_USER -p"$DB_PASS" -e "
            CREATE TABLE IF NOT EXISTS Employee (
            ID INT AUTO_INCREMENT PRIMARY KEY,
            Name VARCHAR(255) NOT NULL,
            Email VARCHAR(255) UNIQUE NOT NULL,
            Department VARCHAR(100),
            Status VARCHAR(50),
            Role VARCHAR(100)
            );
        "
        echo "Schema initialization successful."
        EOT
        ]

        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group"         = aws_cloudwatch_log_group.portal_logs.name
                "awslogs-region"        = var.region
                "awslogs-stream-prefix" = "ecsdb-init"
            }
        }
    }])
    tags = {
        Environment = var.env
        Name        = "${var.env}-portal-task"
    }
}


resource "aws_ssm_parameter" "k3s_kubeconfig" {
  name = "/dev-portal/k3s/kubeconfig"
  type = "SecureString"
  value = "waiting-for-ec2-boot" 

  lifecycle {
    ignore_changes = [ value ]
  }
}