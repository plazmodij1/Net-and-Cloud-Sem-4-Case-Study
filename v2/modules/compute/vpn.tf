resource "aws_instance" "vpn" {
    ami                             = "ami-01f79b1e4a5c64257"
    instance_type                   = var.vpn_instance
    subnet_id                       = var.vpn_public_subnet
    associate_public_ip_address     = true
    vpc_security_group_ids          = [aws_security_group.vpn.id]
    key_name                        = "dev-vpn-key"

    tags = {
        Name = "${var.env}-vpn-instance"
    }
    user_data = file("vpn-setup.sh")
}