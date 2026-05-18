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

#Read storage module outputs from S3 state
data "terraform_remote_state" "storage" {
    backend = "s3"
    config = {
        bucket = "dev-s3-bucket-571238153"
        key = "v2/env/dev/storage/terraform.tfstate"
        region = var.region
        encrypt = true
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

module "compute" {
    source = "../../../modules/compute"

    region = var.region
    env = var.env
    email = var.email

    #Networking linkages
    vpc_public = data.terraform_remote_state.networking.outputs.vpc_public
    vpc_private = data.terraform_remote_state.networking.outputs.vpc_private
    cidr_block_vpc_public = data.terraform_remote_state.networking.outputs.cidr_block_vpc_public
    lambda_private_subnet = data.terraform_remote_state.networking.outputs.lambda_private_subnet
    alb_public_subnets = data.terraform_remote_state.networking.outputs.alb_public_subnets
    vpn_public_subnet = data.terraform_remote_state.networking.outputs.vpn_public_subnet

    #Storage linkages
    db_name = data.terraform_remote_state.storage.outputs.db_name
    proxy_endpoint = data.terraform_remote_state.storage.outputs.proxy_endpoint
    db_secret_arn = data.terraform_remote_state.storage.outputs.db_secret_arn


    lambda_zip = "../../../modules/compute/lambda"
}