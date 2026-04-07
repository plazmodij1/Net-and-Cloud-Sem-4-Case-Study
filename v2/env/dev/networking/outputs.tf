output "vpc_public" {
    description = "Application Load Balancer ARN"
    value       = module.networking.vpc_public
}

output "vpc_private" {
    description = "Application Load Balancer ARN"
    value       = module.networking.vpc_private
}

output "cidr_block_vpc_private" {
    description = "Application Load Balancer ARN"
    value       = module.networking.cidr_block_vpc_private
}

output "cidr_block_vpc_public" {
    description = "Application Load Balancer ARN"
    value       = module.networking.cidr_block_vpc_public
}

output "alb_public_subnets" {
    description = "Application Load Balancer ARN"
    value       = module.networking.alb_public_subnets
}

output "lambda_private_subnet" {
    description = "Application Load Balancer ARN"
    value       = module.networking.lambda_private_subnet
}

output "vpn_public_subnet" {
    description = "Application Load Balancer ARN"
    value       = module.networking.vpn_public_subnet
}

output "grafana_private_subnet" {
    description = "Application Load Balancer ARN"
    value       = module.networking.grafana_private_subnet
}

output "db_subnet_group" {
    description = "Application Load Balancer ARN"
    value       = module.networking.db_subnet_group
}

output "proxy_subnets" {
    description = "Application Load Balancer ARN"
    value       = module.networking.proxy_subnets
}