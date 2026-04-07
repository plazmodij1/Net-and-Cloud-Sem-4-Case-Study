resource "aws_rds_cluster" "main" {
    cluster_identifier      = "${var.env}-aurora-cluster"
    engine                  = "aurora-mysql"
    engine_version          = "8.0.mysql_aurora.3.10.3"
    availability_zones      = ["eu-central-1a", "eu-central-1b"]
    database_name           = var.db_name
    master_username         = var.db_username
    master_password         = random_password.db-pass.result

    deletion_protection     = false
    skip_final_snapshot     = true
    
    db_subnet_group_name    = var.db_subnet_group
    vpc_security_group_ids  = [aws_security_group.db.id]
    storage_encrypted       = true
    
    enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

    lifecycle {
        ignore_changes = [availability_zones]
    }

    tags = {
        Environment = "${var.env}"
        Name        = "RDS-Instance"
    }
}

resource "aws_rds_cluster_instance" "writer" {
    identifier                  = "${var.env}-aurora-writer"
    cluster_identifier          = aws_rds_cluster.main.id
    instance_class              = var.writer_instance
    engine                      = aws_rds_cluster.main.engine
    engine_version              = aws_rds_cluster.main.engine_version
    
    monitoring_interval         = 60
    monitoring_role_arn         = aws_iam_role.rds_monitoring.arn
    auto_minor_version_upgrade  = true

    promotion_tier  = 0
    depends_on      = [ aws_iam_role.rds_monitoring, aws_iam_role_policy_attachment.rds_monitoring ]
}

resource "aws_db_proxy" "main" {
    name                    = "${var.env}-proxy"
    debug_logging           = false
    engine_family           = "MYSQL"
    idle_client_timeout     = 1800
    require_tls             = false
    role_arn                = aws_iam_role.rds_proxy.arn
    vpc_security_group_ids  = [aws_security_group.proxy.id]
    vpc_subnet_ids          = var.proxy_subnets

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