resource "aws_vpc" "public" {
    cidr_block = var.cidr_block_vpc_public

    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "${var.env}-vpc-pub"
    }
}

resource "aws_vpc" "private" {
    cidr_block = var.cidr_block_vpc_private

    enable_dns_hostnames = true
    enable_dns_support = true


    tags = {
        Name = "${var.env}-vpc-priv"
    }
}

