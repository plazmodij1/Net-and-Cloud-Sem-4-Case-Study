output "vpc_public" {
    description = "Public VPC ID"
    value       = module.networking.vpc_public
}

output "vpc_private" {
    description = "Private VPC ID"
    value       = module.networking.vpc_private
}

output "cidr_block_vpc_private" {
    description = "CIDR block for the private VPC"
    value       = module.networking.cidr_block_vpc_private
}

output "cidr_block_vpc_public" {
    description = "CIDR block for the public VPC"
    value       = module.networking.cidr_block_vpc_public
}

output "alb_public_subnets" {
    description = "Public subnets for ALB"
    value       = module.networking.alb_public_subnets
}

output "lambda_private_subnet" {
    description = "Public subnets for Lambda"
    value       = module.networking.lambda_private_subnet
}

output "vpn_public_subnet" {
    description = "Public subnets for VPN"
    value       = module.networking.vpn_public_subnet
}

output "grafana_private_subnet" {
    description = "Private subnet for Grafana"
    value       = module.networking.grafana_private_subnet
}

output "db_subnet_group" {
    description = "Subnet group for the database"
    value       = module.networking.db_subnet_group
}

output "proxy_subnets" {
    description = "Subnets for the RDS proxy"
    value       = module.networking.proxy_subnets
}

output "grafana_discovery_service_arn" {
    description = "ARN of the Grafana discovery service"
    value       = module.networking.grafana_discovery_service_arn
}