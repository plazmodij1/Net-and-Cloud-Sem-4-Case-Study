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

  ingress {
    description = "Allow HTTPS traffic"
    from_port = 443
    to_port = 443
    protocol = "tcp"
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
  vpc_id = var.vpc_private

  tags = {
    Environment = var.env
    Name = "${var.env}-ecs-execution-role"
  }
}

#Accept traffic from ALB
resource "aws_vpc_security_group_ingress_rule" "ecs_portal_alb" {
  security_group_id = aws_security_group.ecs_portal.id
  description = "Allow traffic from ALB"
  from_port = 8080
  to_port = 8080
  ip_protocol = "tcp"

  cidr_ipv4 = var.cidr_block_vpc_public
}

#HTTPS for AWS API calls
resource "aws_vpc_security_group_egress_rule" "ecs_portal_https" {
  security_group_id = aws_security_group.ecs_portal.id
  description = "Allow HTTPS for AWS API calls (Secrets Manager, ECR)"
  from_port = 443
  to_port = 443
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
}

#Allows MySQL traffic to RDS Proxy
resource "aws_vpc_security_group_egress_rule" "ecs_portal_mysql" {
  security_group_id = aws_security_group.ecs_portal.id
  description = "Allow MySQL traffic to RDS Proxy"
  from_port = 3306
  to_port = 3306
  ip_protocol = "tcp"
  referenced_security_group_id = var.rds_proxy_sg_id
}

#k8s security group
resource "aws_security_group" "k8s_sg" {
  name = "${var.env}-k8s-sg"
  description = "Allow internal VPC traffic to Kubernetes"
  vpc_id = var.vpc_public

  # Allow your Node.js Fargate containers to talk to the K8s API (Port 6443)
  ingress {
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = [var.cidr_block_vpc_public]
  }
  
  # Egress: Allow the cluster to download images from the internet
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}