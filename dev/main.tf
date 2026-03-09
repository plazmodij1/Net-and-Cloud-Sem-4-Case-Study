# Provider block
provider "aws" {
    profile = var.profile
    region = var.region
}

resource "aws_rds_cluster" "main" {
    cluster_identifier = "${var.dev}-aurora-cluster"
    engine = "aurora-mysql"
    engine_version = "8.0.mysql_aurora.3.04.1"
    availability_zones = ["eu-central-1a", "eu-central-1b"]
    master_username = var.db-username
    master_password = var.db-password

    deletion_protection = false
    skip_final_snapshot = true
    
    db_subnet_group_name = aws_db_subnet_group.main.name
    vpc_security_group_ids = [aws_security_group.db.id]
    storage_encrypted = true

    enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
}

resource "aws_rds_cluster_instance" "writer" {
    identifier = "${var.dev}-aurora-writer"
    cluster_identifier = aws_rds_cluster.main.id
    instance_class = "db.t3.medium"
    engine = aws_rds_cluster.main.engine
    engine_version = aws_rds_cluster.main.engine_version
    
    monitoring_interval = 60
    monitoring_role_arn = aws_iam_role.rds_monitoring.arn
    auto_minor_version_upgrade = true

    promotion_tier = 0
    depends_on = [ aws_iam_role.rds_monitoring, aws_iam_role_policy_attachment.rds_monitoring ]
}

resource "aws_rds_cluster_instance" "reader" {
    identifier = "${var.dev}-aurora-reader"
    cluster_identifier = aws_rds_cluster.main.id
    instance_class = "db.t3.medium"
    engine = aws_rds_cluster.main.engine
    engine_version = aws_rds_cluster.main.engine_version

    monitoring_interval = 60
    monitoring_role_arn = aws_iam_role.rds_monitoring.arn
    auto_minor_version_upgrade = true

    depends_on = [ aws_rds_cluster_instance.writer ]
}

resource "aws_lambda_function" "lambda"{
    
}