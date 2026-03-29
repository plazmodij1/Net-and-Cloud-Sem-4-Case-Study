
# Security group for the Grafana Fargate task allowing inbound traffic on port 3000 from the public VPC
resource "aws_security_group" "fargate" {
    name = "${var.env}-fargate-sg"
    vpc_id = var.vpc_private
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