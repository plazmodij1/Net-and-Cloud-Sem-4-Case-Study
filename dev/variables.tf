variable  "region" {
    default = "eu-central-1"
}

variable "private_subnet_cidrs" {
    type = map(object({
        cidr_block = string
        az = string
    }))
    default = {
      "data" = {
        cidr_block = "10.0.0.1/24"
        az = "eu-central-1"
      }
      "vpn" = {
        cidr_block = "10.0.0.2/24"
        az = "eu-central-1"     
      }
      "app" = {
        cidr_block = "10.0.0.3/24"
        az = "eu-central-1"
      }
    }
}

variable "public_subnet_cidrs" {
    type = map(object({
        cidr_block = string
        az = string
    }))
    default = {
      "dmz-1" = {
        cidr_block = "10.1.0.1/24"
        az = "eu-central-1a"        
      }
      "dmz-2" = {
        cidr_block = "10.2.0.1/24"
        az = "eu-central-1b"
      }
    }
}