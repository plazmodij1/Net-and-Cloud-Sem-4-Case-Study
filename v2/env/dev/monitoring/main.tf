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
        key = "env/dev/monitoring/terraform.tfstate"
        region = var.region
        encrypt = true
    }
}


module "monitoring" {
    source = "../../../modules/monitoring"
    
    region = var.region
    env = var.env

    cidr_block_vpc_public = data.terraform_remote_state.networking.outputs.cidr_blocks_vpc_public
    lambda_private_subnet = data.terraform_remote_state.networking.outputs.lambda_private_subnet
    grafana_private_subnet = data.terraform_remote_state.networking.outputs.grafana_private_subnet
    vpc_private = data.terraform_remote_state.networking.outputs.vpc_private
}