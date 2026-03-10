resource "aws_vpc" "public" {
    cidr_block = var.cidr_block_vpc_public

    tags = {
        Name = "${var.dev}-vpc-pub"
    }
}

resource "aws_vpc" "private" {
    cidr_block = var.cidr_block_vpc_priv

    enable_dns_hostnames = true
    enable_dns_support = true


    tags = {
        Name = "${var.dev}-vpc-priv"
    }
}

