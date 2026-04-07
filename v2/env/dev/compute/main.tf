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
#Read storage module outputs from S3 state
data "terraform_remote_state" "storage" {
    backend = "s3"
    config = {
        bucket = "dev-s3-bucket-571238153"
        key = "env/dev/storage/terraform.tfstate"
        region = var.region
        encrypt = true
    }
}

module "compute" {
    source = "../../modules/compute"

    env = var.dev
    
    #Networking linkages
    vpc_public = data.terraform_remote_state.networking.outputs.vpc_public
    vpc_private = data.terraform_remote_state.networking.outputs.vpc_private
    cidr_block_vpc_private = data.terraform_remote_state.networking.outputs.cidr_block_vpc_private
    lambda_private_subnet = data.terraform_remote_state.networking.outputs.lambda_private_subnet
    alb_public_subnets = data.terraform_remote_state.networking.outputs.alb_public_subnets
    vpn_public_subnet = data.terraform_remote_state.networking.outputs.vpn_public_subnet

    #Storage linkages
    db_name = data.terraform_remote_state.storage.outputs.db_name
    proxy_endpoint = data.terraform_remote_state.storage.outputs.proxy_endpoint

    grafana_image = data.terraform_remote_state.monitoring.outputs.grafana_image
    vpn_script = vpn-setup.sh
}