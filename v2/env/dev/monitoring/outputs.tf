output "fargate_sg_id" {
    description = "Fargate security group ID"
    value       = module.monitoring.fargate_sg_id
}