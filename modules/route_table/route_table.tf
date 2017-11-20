variable "aws_route_table_variables" {
    type = "map"
    description = "Route Table変数"

    default = {
      name       = ""
      vpc_id     = ""
      cidr_block = ""
      gateway_id = ""
    }
}

/**
 * Route Table作成
 * https://www.terraform.io/docs/providers/aws/r/route_table.html
 */
resource "aws_route_table" "route_table" {
  vpc_id = "${var.aws_route_table_variables["vpc_id"]}"

  route {
    cidr_block = "${var.aws_route_table_variables["cidr_block"]}"
    gateway_id = "${var.aws_route_table_variables["gateway_id"]}"
  }

  tags {
    Name = "${var.aws_route_table_variables["name"]}"
  }
}

output "route_table_id" {
    value = "${aws_route_table.route_table.id}"
}
