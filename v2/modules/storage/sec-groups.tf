# Security group for the RDS Proxy allowing inbound MySQL traffic from the Lambda function
resource "aws_security_group" "proxy" {
    name    = "${var.env}-proxy-sg"
    vpc_id  = var.vpc_private_id

    ingress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        cidr_blocks     = [var.cidr_block_vpc_private]
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

# Security group for the RDS Aurora database cluster allowing outbound traffic
resource "aws_security_group" "db" {
    name    = "${var.env}-db-sg"
    vpc_id  = var.vpc_private_id

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}
