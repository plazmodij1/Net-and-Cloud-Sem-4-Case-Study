



################REMOVE THE COMMENTS FOR BIG TRAFFIC#######################

#resource "aws_rds_cluster_instance" "reader" {
#    identifier                  = "${var.env}-aurora-reader"
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





