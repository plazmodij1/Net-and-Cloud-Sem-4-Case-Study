resource "aws_subnet" "private" {
    for_each = var.private_subnet_cidrs

    vpc_id = aws_vpc.private.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az
    
  #subnet_id = aws_subnet.private[keys(aws_subnet.private)[0]].id
}

resource "aws_subnet" "public" {
    for_each = var.public_subnet_cidrs

    vpc_id = aws_vpc.public.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az  
}

resource "aws_db_subnet_group" "main" {
    name = "${var.dev}-db-subnet-group"
    subnet_ids = [aws_subnet.private["data-1"].id, aws_subnet.private["data-2"].id]

    tags = {
        Name = "${var.dev}-db-subnet-group"
    }
}