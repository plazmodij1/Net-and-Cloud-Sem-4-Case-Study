output "grafana_cluster_arn" {
    description = "ARN of the Grafana ECS cluster"
    value = aws_ecs_cluster.grafana.arn
}

output "cloudwatch_log_group_arn" {
    description = "ARN of Cloudwatch log group for Grafana"
    value = aws_cloudwatch_log_group.grafana.arn
}

output "grafana_task_definition_arn" {
    description = "ARN of the Grafana task definition cluster"
    value = aws_ecs_task_definition.grafana.arn
}

output "grafana_ecs_service_arn" {
    description = "ARN of Grafana ECS service"
    value = aws_ecs_service.grafana.arn
}

output "fargate_sg_id" {
    value = aws_security_group.fargate.id
}
