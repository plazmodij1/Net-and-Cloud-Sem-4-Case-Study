resource "aws_subnet" "private" {
    for_each = var.private_subnet_cidrs

    vpc_id = var.vpc_private
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az
    
}

resource "aws_subnet" "public" {
    for_each = var.public_subnet_cidrs

    vpc_id = var.vpc_public
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az  
}

resource "aws_db_subnet_group" "main" {
    name = "${var.env}-db-subnet-group"
    subnet_ids = [aws_subnet.private["data-1"].id, aws_subnet.private["data-2"].id]

    tags = {
        Name = "${var.env}-db-subnet-group"
    }
}