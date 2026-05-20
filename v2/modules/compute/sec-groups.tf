# Security group for the Application Load Balancer allowing inbound HTTP traffic from anywhere
resource "aws_security_group" "alb" {
  name   = "${var.env}-alb-sg"
  vpc_id = var.vpc_public

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the Lambda function allowing outbound traffic to the VPC
resource "aws_security_group" "lambda" {
  name   = "${var.env}-lambda-sg"
  vpc_id = var.vpc_private

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the VPN EC2 instance allowing inbound SSH and VPN UDP traffic
resource "aws_security_group" "vpn" {
  name   = "${var.env}-vpn-sg"
  vpc_id = var.vpc_public

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_portal" {
  name = "${var.env}-ecs-portal-sg"
  description = "Allow inbound traffic from ALB to ECS Fargate tasks"
  vpc_id = var.vpc_public

  ingress = {
    description = "Allow traffic from ALB"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress = {
    description = "Allow HTTPS for AWS API calls (Secrets Manager, ECR)"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress = {
    description = "Allow MySQL traffic to RDS Proxy"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [var.rds_proxy_sg_id]
  }

  tags = {
    Environment = var.env
    Name = "${var.env}-ecs-execution-role"
  }
}
