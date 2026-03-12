resource "aws_service_discovery_private_dns_namespace" "main" {
    name    = "student.internal"
    vpc     = aws_vpc.private.id
}

resource "aws_route53_zone_association" "public_vpn_share" {
    zone_id = aws_service_discovery_private_dns_namespace.main.hosted_zone
    vpc_id  = aws_vpc.public.id
}

resource "aws_service_discovery_service" "grafana" {
    name = "grafana"
    
    dns_config {
        namespace_id = aws_service_discovery_private_dns_namespace.main.id
    
        dns_records {
            ttl = 10
            type = "A"
        }
    
        routing_policy = "MULTIVALUE"
    }

    health_check_custom_config {}
}