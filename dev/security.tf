resource "aws_security_group" "db" {
    name = "${var.dev}-db-sg"
    vpc_id = aws_vpc.private.id

    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = []
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
