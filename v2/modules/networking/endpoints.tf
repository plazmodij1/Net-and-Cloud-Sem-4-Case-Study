
resource "aws_vpc_endpoint" "secrets_manager" {
    vpc_id              = aws_vpc.private.id
    service_name        = "com.amazonaws.${region}.secretsmanager"
    vpc_endpoint_type   = "Interface"

    subnet_ids          = [aws_subnet.private["data-1"].id, aws_subnet.private["data-2"].id]
    security_group_ids  = [aws_security_group.vpc_endpoints.id]
    private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
    vpc_id              = aws_vpc.private.id
    service_name        = "com.amazonaws.${region}.s3"
    vpc_endpoint_type   = "Gateway"
    
    route_table_ids          = [aws_route_table.private.id]    
}

resource "aws_vpc_endpoint" "ecr_api" {
    vpc_id              = aws_vpc.private.id
    service_name        = "com.amazonaws.${region}.ecr.api"
    vpc_endpoint_type   = "Interface"
    private_dns_enabled = true

    subnet_ids          = [aws_subnet.private["data-1"].id, aws_subnet.private["data-2"].id]
    security_group_ids  = [aws_security_group.vpc_endpoints.id]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
    vpc_id              = aws_vpc.private.id
    service_name        = "com.amazonaws.${var.region}.ecr.dkr"
    vpc_endpoint_type   = "Interface"
    private_dns_enabled = true

    subnet_ids          = [aws_subnet.private["data-1"].id, aws_subnet.private["data-2"].id]
    security_group_ids  = [aws_security_group.vpc_endpoints.id]
}

resource "aws_vpc_endpoint" "grafana_logs" {
    vpc_id                  = aws_vpc.private.id
    service_name            = "com.amazonaws.${region}.logs"
    vpc_endpoint_type       = "Interface"
    private_dns_enabled     = true

    subnet_ids          = [aws_subnet.private["data-1"].id, aws_subnet.private["data-2"].id]
    security_group_ids  = [aws_security_group.vpc_endpoints.id]
}

resource "aws_vpc_endpoint" "cloudwatch" {
    vpc_id              = aws_vpc.private.id
    service_name        = "com.amazonaws.eu-central-1.monitoring"
    vpc_endpoint_type   = "Interface"

    subnet_ids          = [aws_subnet.private["data-1"].id, aws_subnet.private["data-2"].id]
    security_group_ids  = [aws_security_group.vpc_endpoints.id]

    private_dns_enabled = true
}

