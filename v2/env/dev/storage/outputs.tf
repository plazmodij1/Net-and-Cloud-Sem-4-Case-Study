output "db_name" {
    description = "Database name"
    value       = module.storage.db_name
}

output "proxy_endpoint" {
    description = "Proxy endpoint for the RDS"
    value       = module.storage.proxy_endpoint
}

output "db_secret_arn" {
    description = "ARN of the database secrets manager"
    value = module.storage.db_secret_arn
}

output "rds_proxy_sg_id" {
    description = "ID of the RDS Proxy security group"
    value = module.storage.rds_proxy_sg_id
}