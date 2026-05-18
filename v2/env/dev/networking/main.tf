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


module "networking" {
    source = "../../../modules/networking"

    region = var.region
    env = var.env
    email = var.email

    eks_cluster_name = "${var.env}-cluster"
}