resource "aws_vpc" "public" {
    cidr_block = var.cidr_block_vpc_public

    tags = {
        Name = "${var.dev}-vpc-pub"
    }
}

resource "aws_vpc" "private" {
    cidr_block = var.cidr_block_vpc_priv

    tags = {
        Name = "${var.dev}-vpc-priv"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.public.id
    
    tags = {
        Name = "${var.dev}-igw"
    }
}