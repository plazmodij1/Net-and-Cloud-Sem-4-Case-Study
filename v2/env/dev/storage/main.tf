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
data "terraform_remote_state" "networking" {
    backend = "s3"
    config = {
        bucket = "dev-s3-bucket-571238153"
        key = "v2/env/dev/networking/terraform.tfstate"
        region = var.region
        encrypt = true
    }
}

module "storage" {
    source = "../../../modules/storage"

    region = var.region
    env = var.env

    vpc_private_id = data.terraform_remote_state.networking.outputs.vpc_private

    cidr_block_vpc_private = data.terraform_remote_state.networking.outputs.cidr_block_vpc
    db_subnet_group = data.terraform_remote_state.networking.outputs.db_subnet_group
    proxy_subnets = data.terraform_remote_state.networking.outputs.proxy_subnets

}