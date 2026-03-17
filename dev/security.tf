resource "aws_security_group" "alb" {
    name    = "${var.dev}-alb-sg"
    vpc_id  = aws_vpc.public.id

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

resource "aws_security_group" "proxy" {
    name    = "${var.dev}-proxy-sg"
    vpc_id  = aws_vpc.private.id

    ingress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        security_groups = [aws_security_group.lambda.id]
    }

    egress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        security_groups = [aws_security_group.db.id]
    }
}

resource "aws_security_group_rule" "allow_proxy_to_rds" {
    type                        = "ingress"
    from_port                   = 3306
    to_port                     = 3306
    protocol                    = "tcp"
    security_group_id           = aws_security_group.db.id
    source_security_group_id    = aws_security_group.proxy.id
}

resource "aws_security_group" "lambda"{
    name    = "${var.dev}-lambda-sg"
    vpc_id  = aws_vpc.private.id

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "db" {
    name    = "${var.dev}-db-sg"
    vpc_id  = aws_vpc.private.id

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "fargate" {
    name = "${var.dev}-fargate-sg"
    vpc_id = aws_vpc.private.id

    ingress {
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = [var.cidr_block_vpc_public]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "vpc_endpoints" {
    name    = "${var.dev}-vpc-endpoints-sg"
    vpc_id  = aws_vpc.private.id

    ingress {
        description     = "Allow Lambda and Fargate to access VPC Endpoints"
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        security_groups = [
            aws_security_group.lambda.id,
            aws_security_group.fargate.id
        ]
    }
}

resource "aws_security_group" "vpn" {
    name = "${var.dev}-vpn-sg"
    vpc_id = aws_vpc.public.id

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
