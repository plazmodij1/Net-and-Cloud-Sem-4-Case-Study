output "vpc_public" {
    value = aws_vpc.public.id
}

output "vpc_private" {
    value = aws_vpc.private.id
}

output "cidr_block_vpc_private" {
    value = var.cidr_block_vpc_private
}

output "cidr_block_vpc_public" {
    value = var.cidr_block_vpc_public
}

output "alb_public_subnets" {
    value = [aws_subnet.public["dmz-1"].id, aws_subnet.public["dmz-2"].id]
}

output "lambda_private_subnet" {
    value = [aws_subnet.private["app"].id]
}

output "vpn_public_subnet" {
    value = aws_subnet.public["vpn"].id
}

output "grafana_private_subnet" {
    value = [aws_subnet.private["data-1"].id, aws_subnet.private["data-2"].id]
}

output "db_subnet_group" {
    value = aws_db_subnet_group.main.name
}

output "proxy_subnets" {
    value = [for s in aws_subnet.private : s.id]
}