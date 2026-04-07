provider "aws" {
    region  = var.region
}

terraform {
    backend "s3"{}

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>6.0"
        }
    }
}

#Read networking module outputs from S3 state
data "terraform_remote_state" "compute" {
    backend = "s3"
    config = {
        bucket = "dev-s3-bucket-571238153"
        key = "env/dev/monitoring/terraform.tfstate"
        region = var.region
        encrypt = true
    }
}

#Read networking module outputs from S3 state
data "terraform_remote_state" "networking" {
    backend = "s3"
    config = {
        bucket = "dev-s3-bucket-571238153"
        key = "env/dev/monitoring/terraform.tfstate"
        region = var.region
        encrypt = true
    }
}

module "storage" {
    source = "../../../modules/storage"

    region = var.region
    env = var.env

    lambda_sg_id = data.terraform_remote_state.compute.outputs.lambda_sg_id

    db_subnet_group = data.terraform_remote_state.networking.outputs.db_subnet_group
    proxy_subnets = data.terraform_remote_state.networking.outputs.proxy_subnets

}