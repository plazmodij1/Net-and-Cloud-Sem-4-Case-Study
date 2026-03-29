resource "random_password" "db-pass"{
    length              = 32
    special             = true
    override_special    = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_cred" {
    name = "${var.env}-db-credentials"

    recovery_window_in_days = 0

    tags = {
        Name = "${var.env}-db-credentials"
    }
}

resource "aws_secretsmanager_secret_version" "db_cred_version"{
    secret_id       = aws_secretsmanager_secret.db_cred.id
    secret_string   = jsonencode({
        username    = "${var.db_username}"
        password    = random_password.db-pass.result
        host        = aws_rds_cluster.main.endpoint
        port        = var.db_port
        dbname      = aws_rds_cluster.main.database_name
    })
}
