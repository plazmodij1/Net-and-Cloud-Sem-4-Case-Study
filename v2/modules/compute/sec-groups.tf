# Security group for the Application Load Balancer allowing inbound HTTP traffic from anywhere
resource "aws_security_group" "alb" {
    name    = "${var.env}-alb-sg"
    vpc_id  = var.vpc_public

    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

# Security group for the Lambda function allowing outbound traffic to the VPC
resource "aws_security_group" "lambda"{
    name    = "${var.env}-lambda-sg"
    vpc_id  = var.vpc_private

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

# Security group for the VPN EC2 instance allowing inbound SSH and VPN UDP traffic
resource "aws_security_group" "vpn" {
    name = "${var.env}-vpn-sg"
    vpc_id = var.vpc_public

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 51820
        to_port         = 51820
        protocol        = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

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
            var.fargate_sg_id, aws_security_group.lambda
        ]
    }
}
