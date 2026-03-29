#This file is for initial setup of s3 bucket in the environment

#resource "aws_s3_bucket" "main" {
#    bucket = "${var.env}-s3-bucket-571238153"
#}


#resource "aws_s3_bucket_versioning" "main" {
#    bucket = aws_s3_bucket.main.id
#    versioning_configuration {
#        status = "Enabled"
#    }
#}

#resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
#    bucket = aws_s3_bucket.main.id
#    rule {
#        apply_server_side_encryption_by_default {
#            sse_algorithm = "AES256"
#        }
#    }
#}
