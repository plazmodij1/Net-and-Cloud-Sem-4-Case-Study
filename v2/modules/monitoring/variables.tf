variable "env" {
    type = string
}

variable "region" {
    type = string
}

variable "grafana_image" {
    type = string
}

variable "cidr_block_vpc_public" {
    type = string
}

variable "lambda_private_subnet" {
    type = list(string)
}

variable "ecr_repo_name" {
    description = "Name of the ECR repository which contains the Grafana image"
    type = string
}

variable "grafana_private_subnet" {
    type = list(string)
}

variable "vpc_private" {
    type = string
}