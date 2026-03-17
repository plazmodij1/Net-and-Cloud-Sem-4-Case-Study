variable  "region" {
    default = "eu-central-1"
}

variable "db_username"{
    default = "MarkoAdminStudent"
}

variable "db_name" {
    default = "mydatabase"
}

variable "instance" {
  default = "db.t3.medium"
}

variable "db_port" {
  default = "3306"
}

variable "private_subnet_cidrs" {
    type = map(object({
        cidr_block = string
        az = string
        tags = string
    }))
    default = {
      "data-1" = {
        cidr_block = "10.0.1.0/24"
        az = "eu-central-1a"
        tags = "data-1-subnet"
      }
      "data-2" = {
        cidr_block = "10.0.2.0/24"
        az = "eu-central-1b"
        tags = "data-2-subnet"
      }
      "vpn" = {
        cidr_block = "10.0.3.0/24"
        az = "eu-central-1a"
        tags = "vpn-subnet"
      }
      "app" = {
        cidr_block = "10.0.4.0/24"
        az = "eu-central-1a"
        tags = "app-subnet"
      }
    }
}

variable "public_subnet_cidrs" {
    type = map(object({
        cidr_block = string
        az = string
        tags = string
    }))
    default = {
      "dmz-1" = {
        cidr_block = "10.1.1.0/24"
        az = "eu-central-1a"
        tags = "dmz-1-subnet"
      }
      "dmz-2" = {
        cidr_block = "10.1.2.0/24"
        az = "eu-central-1b"
        tags = "dmz-2-subnet"
      }
    }
}