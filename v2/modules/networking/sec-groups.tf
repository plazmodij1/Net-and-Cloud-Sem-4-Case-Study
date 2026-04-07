resource "aws_security_group" "vpc_endpoints" {
    name    = "${var.env}-vpc-endpoints-sg"
    vpc_id  = aws_vpc.private.id

    ingress {
        description     = "Allow Lambda and Fargate to access VPC Endpoints"
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}