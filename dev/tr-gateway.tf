resource "aws_ec2_transit_gateway" "main" {
    description = "Main gateway between VPCs"

    default_route_table_association = "enable"
    default_route_table_propagation = "enable"

    tags = {
        Name = "${var.dev}-tr-gt-main"
    }
}