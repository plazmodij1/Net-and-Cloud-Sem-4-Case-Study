output "db_name" {
    value = var.db_name
}

output "proxy_endpoint" {
    value = aws_db_proxy.main.endpoint
}