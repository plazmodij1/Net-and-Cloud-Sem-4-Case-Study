resource "aws_iam_role" "rds_monitoring"{
    name = "${var.env}-db-monitor-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{ 
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = { Service = "monitoring.rds.amazonaws.com" }
        }]
    })
}

resource "aws_iam_role" "rds_proxy" {
    name = "${var.env}-rds-proxy-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [{ 
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = { Service = "rds.amazonaws.com" }
        }]
    })
}

resource "aws_iam_role_policy" "rds-proxy" {
    name   = "${var.env}-rds-proxy-policy"
    role   = aws_iam_role.rds_proxy.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = ["secretsmanager:GetSecretValue"]
            Resource = aws_secretsmanager_secret.db_cred.arn
        }]
    })          
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
    role        = aws_iam_role.rds_monitoring.name
    policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
