# Security group for VPC Endpoints allowing inbound HTTPS traffic from Lambda and Fargate
resource "aws_security_group" "vpc_endpoints" {
    name    = "${var.env}-vpc-endpoints-sg"
    vpc_id  = aws_vpc.private.id

    ingress {
        description     = "Allow Lambda and Fargate to access VPC Endpoints"
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        security_groups = [
            var.fargate_sg_id, var.lambda_sg_id
        ]
    }
}
