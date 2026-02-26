# Provider block
provider "aws" {
    profile = var.profile
    region = var.region
}



#resource "aws_instance" "server" {
#    ami = "ami-01f79b1e4a5c64257"
#    instance_type = "t3.micro"
#
#    subnet_id = aws_subnet.private.id
#
#    tags = {
#        Name = "Web-Server"
#    }
#
#}   