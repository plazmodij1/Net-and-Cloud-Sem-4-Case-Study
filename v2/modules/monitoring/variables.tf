variable "env" {
    type = string
}

variable "region" {
    type = string
}

variable "grafana_image" {
    default = "grafana"
}

variable "cidr_block_vpc_public" {
    type = string
}

variable "lambda_private_subnet" {
    type = list(string)
}

variable "ecr_repo_name" {
    default = "dev-grafana-repo"
}

variable "grafana_private_subnet" {
    type = list(string)
}

variable "vpc_private" {
    type = string
}

variable "grafana_discovery_service_arn" {
    type = string
}