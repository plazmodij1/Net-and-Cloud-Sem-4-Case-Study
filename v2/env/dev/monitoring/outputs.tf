output "fargate_sg_id" {
    description = "Application Load Balancer ARN"
    value       = module.monitoring.fargate_sg_id
}