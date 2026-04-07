variable "env" {
    type = string
}

variable "region" {
    type = string
}   

variable "vpc_private_id" {
  type = string
}

variable "cidr_block_vpc_private" {
  type = string
}

variable "db_username"{
    default = "MarkoAdminStudent"
}

variable "db_name" {
    default = "mydatabase"
}

variable "writer_instance" {
  default = "db.t3.medium"
}

variable "db_port" {
  default = "3306"
}

variable "db_subnet_group" {
  type = string
}

variable "proxy_subnets" {
  type = list(string)
}