provider "aws" {
    profile = var.profile
    region  = var.region
}

terraform {
    backend "s3"{
        bucket = "dev-s3-bucket-571238153"
        key = "terraform.tfstate"
        region = "eu-central-1"
        encrypt = true
        profile = "marko-student"
    }

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>6.0"
        }
    }
}

resource "aws_rds_cluster" "main" {
    cluster_identifier      = "${var.dev}-aurora-cluster"
    engine                  = "aurora-mysql"
    engine_version          = "8.0.mysql_aurora.3.10.3"
    availability_zones      = ["eu-central-1a", "eu-central-1b"]
    database_name           = var.db_name
    master_username         = var.db_username
    master_password         = random_password.db-pass.result

    deletion_protection     = false
    skip_final_snapshot     = true
    
    db_subnet_group_name    = aws_db_subnet_group.main.name
    vpc_security_group_ids  = [aws_security_group.db.id]
    storage_encrypted       = true
    
    enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

    lifecycle {
        ignore_changes = [availability_zones]
    }

    tags = {
        Environment = "${var.dev}"
        Name        = "RDS-Instance"
    }
}

resource "aws_rds_cluster_instance" "writer" {
    identifier                  = "${var.dev}-aurora-writer"
    cluster_identifier          = aws_rds_cluster.main.id
    instance_class              = var.instance
    engine                      = aws_rds_cluster.main.engine
    engine_version              = aws_rds_cluster.main.engine_version
    
    monitoring_interval         = 60
    monitoring_role_arn         = aws_iam_role.rds_monitoring.arn
    auto_minor_version_upgrade  = true

    promotion_tier  = 0
    depends_on      = [ aws_iam_role.rds_monitoring, aws_iam_role_policy_attachment.rds_monitoring ]
}

################REMOVE THE COMMENTS FOR BIG TRAFFIC#######################

#resource "aws_rds_cluster_instance" "reader" {
#    identifier                  = "${var.dev}-aurora-reader"
#    cluster_identifier          = aws_rds_cluster.main.id
#    instance_class              = "db.t3.medium"
#    engine                      = aws_rds_cluster.main.engine
#    engine_version              = aws_rds_cluster.main.engine_version
#
#    monitoring_interval         = 60
#    monitoring_role_arn         = aws_iam_role.rds_monitoring.arn
#    auto_minor_version_upgrade  = true
#
#    depends_on = [ aws_rds_cluster_instance.writer ]
#}

resource "aws_lambda_function" "main"{
    filename        = "./hello.zip"
    function_name   = "${var.dev}-lambda"
    role            = aws_iam_role.lambda.arn
    handler         = "hello.handler"
    runtime         = "nodejs22.x"

    source_code_hash    = filebase64sha256("./hello.zip")
    timeout             = 15

    vpc_config {
        security_group_ids  = [aws_security_group.lambda.id]
        subnet_ids          = [aws_subnet.private["app"].id]
    }

    environment {
        variables = {
            DB_HOST = aws_db_proxy.main.endpoint
            DB_NAME = var.db_name
            SECRET_ARN = aws_secretsmanager_secret.db_cred.arn
        }
    }
    tags = {
        Environment = "${var.dev}"
        Name        = "Lambda-instance"
    }
}

resource "aws_lb" "main" {
    name                = "${var.dev}-alb"
    internal            = false
    load_balancer_type  = "application"
    security_groups     = [aws_security_group.alb.id]
    subnets             = [aws_subnet.public["dmz-1"].id, aws_subnet.public["dmz-2"].id]
    
    enable_deletion_protection = false

    tags = {
        Environment = "${var.dev}"
        Name        = "ALB-Instance"
    }
}

resource "aws_db_proxy" "main" {
    name                    = "${var.dev}-proxy"
    debug_logging           = false
    engine_family           = "MYSQL"
    idle_client_timeout     = 1800
    require_tls             = false
    role_arn                = aws_iam_role.rds_proxy.arn
    vpc_security_group_ids  = [aws_security_group.proxy.id]
    vpc_subnet_ids          = [for s in aws_subnet.private : s.id]

    auth {
        auth_scheme = "SECRETS"
        iam_auth    = "DISABLED"
        secret_arn  = aws_secretsmanager_secret.db_cred.arn
    } 
}

resource "aws_db_proxy_target" "aurora" {
    db_proxy_name           = aws_db_proxy.main.name
    target_group_name       = "default"
    db_cluster_identifier   = aws_rds_cluster.main.id
}

resource "aws_instance" "vpn" {
    ami                             = "ami-01f79b1e4a5c64257"
    instance_type                   = "t3.micro"
    subnet_id                       = aws_subnet.public["vpn"].id
    associate_public_ip_address     = true
    vpc_security_group_ids          = [aws_security_group.vpn.id]
    key_name                        = "dev-vpn-key"

    tags = {
        Name = "${var.dev}-vpn-instance"
    }
    user_data = file("vpn-setup.sh")
}