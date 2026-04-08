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