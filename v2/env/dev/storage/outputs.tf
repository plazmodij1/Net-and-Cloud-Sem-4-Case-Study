output "db_name" {
    description = "Application Load Balancer ARN"
    value       = module.storage.db_name
}

output "proxy_endpoint" {
    description = "Application Load Balancer ARN"
    value       = module.storage.proxy_endpoint
}