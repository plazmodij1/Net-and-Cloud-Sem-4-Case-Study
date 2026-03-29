variable "env" {
    type = string
}

#Compute variables

variable "lambda_zip" {
    type = string
}

variable "vpn_instance" {
    type = string
}

variable "vpn_script" {
    type = string
}

#Storage variables
variable "db_name" {
    type = string
}

variable "proxy_endpoint" {
    type = string
}

#Networking variables
variable "vpc_public" {
    type = string    
}

variable "vpc_private" {
    type = string
}

variable "cidr_block_vpc_public" {
    type = string
}

variable "lambda_private_subnet" {
    type = list(string)
}

variable "alb_public_subnets" {
    type = list(string)
}

variable "vpn_public_subnet" {
    type = string
}