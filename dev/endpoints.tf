
resource "aws_vpc_endpoint" "secrets_manager" {
    vpc_id = aws_vpc.private.id
    service_name = "com.amazonaws.${var.region}.secretsmanager"
    vpc_endpoint_type = "Interface"

    subnet_ids = [aws_subnet.private["data-1"].id, aws_subnet.private["data-2"].id]
    security_group_ids = [aws_security_group.vpc_endpoints.id]
    private_dns_enabled = true
}

#resource "aws_vpc_endpoint" "rds-data" {
#    vpc_id = aws_vpc.private.id
#    service_name = "com.amazonaws.${var.region}.rds-data"
#    vpc_endpoint_type = "Interface"
#
#    subnet_ids = [aws_subnet.private["data-1"].id, aws_subnet.private["data-2"].id]
#    security_group_ids = [aws_security_group.vpc-endpoints.id]
#    private_dns_enabled = true
#}