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

data "terraform_remote_state" "monitoring" {
    backend = "s3"
    config = {
        bucket = "dev-s3-bucket-571238153"
        key = "env/dev/monitoring/terraform.tfstate"
        region = var.region
        encrypt = true
    }
}

data "terraform_remote_state" "compute" {
    backend = "s3"
    config = {
        bucket = "dev-s3-bucket-571238153"
        key = "env/dev/monitoring/terraform.tfstate"
        region = var.region
        encrypt = true
    }
}

module "networking" {
    source = "../../../modules/networking"

    region = var.region
    env = var.env

    lambda_sg_id = data.terraform_remote_state.compute.outputs.lambda_sg_id

    fargate_sg_id = data.terraform_remote_state.monitoring.outputs.fargate_sg_id
    
}