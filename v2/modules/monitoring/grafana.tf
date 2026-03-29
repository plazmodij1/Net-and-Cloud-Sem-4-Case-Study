resource "aws_ecs_cluster" "grafana" {
    name = "${var.env}-grafana-cluster"
}

resource "aws_cloudwatch_log_group" "grafana" {
    name = "/ecs/${var.env}-grafana"
    retention_in_days = 7
}

resource "aws_ecs_task_definition" "grafana" {
    family                      = "${var.env}-grafana-task"
    network_mode                = "awsvpc"
    requires_compatibilities    = ["FARGATE"]
    cpu                         = 256
    memory                      = 512
    execution_role_arn          = aws_iam_role.ecs_execution_grafana.arn
    task_role_arn               = aws_iam_role.ecs_task_grafana.arn

    container_definitions = jsonencode([{
        name        = var.grafana_image
        image       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}..amazonaws.com/${var.grafana_image}:latest"
        essential   = true

        portMappings = [{
            containerPort   = 3000
            hostPort        = 3000
            protocol        = "tcp"
            }]
        logConfiguration = {
            logDriver = "awslogs"
            options = {
                "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
                "awslogs-region"        = var.region
                "awslogs-stream-prefix" = "ecs"
            }
        }
    }])
}

resource "aws_ecs_service" "grafana" {
    name            = "${var.env}-grafana-service"
    cluster         = aws_ecs_cluster.grafana.arn
    task_definition = aws_ecs_task_definition.grafana.arn
    launch_type     = "FARGATE"
    desired_count   = 1

    network_configuration {
        subnets             = var.grafana_private_subnet
        security_groups     = [aws_security_group.fargate.id]
        assign_public_ip    = false
    }

    service_registries {
        registry_arn = aws_service_discovery_service.grafana.arn
    }
}