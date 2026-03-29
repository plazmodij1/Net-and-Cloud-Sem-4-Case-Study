output "vpc_public" {
    value = aws_vpc.public.id
}

output "vpc_private" {
    value = aws_vpc.private.id
}

output "cidr_block_vpc_private" {
    value = var.cidr_block_vpc_private
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