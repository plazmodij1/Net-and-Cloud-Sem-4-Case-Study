output "db_name" {
    value = var.db_name
}

output "proxy_endpoint" {
    value = aws_db_proxy.main.endpoint
}

output "db_secret_arn" {
    value = aws_secretsmanager_secret.db_cred.arn
}

output "rds_proxy_sg_id" {
    value = aws_security_group.proxy.id
}