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

#Read compute module outputs from S3 state
data "terraform_remote_state" "compute" {
    backend = "s3"
    config = {
        bucket = "dev-s3-bucket-571238153"
        key = "v2/env/dev/compute/terraform.tfstate"
        region = var.region
        encrypt = true
    }
}

module "security" {
    source = "../../../modules/security"

    region = var.region
    env = var.env
    email = var.email

    alb_arn = data.terraform_remote_state.compute.outputs.alb_arn
}