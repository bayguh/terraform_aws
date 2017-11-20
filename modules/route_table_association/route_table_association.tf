variable "aws_route_table_association_variables" {
    type = "map"
    description = "Route Table Association変数"

    default = {
      subnet_id      = ""
      route_table_id = ""
    }
}

/**
 * Route Table Association作成
 * https://www.terraform.io/docs/providers/aws/r/route_table_association.html
 */
resource "aws_route_table_association" "route_table_association" {
  subnet_id      = "${var.aws_route_table_association_variables["subnet_id"]}"
  route_table_id = "${var.aws_route_table_association_variables["route_table_id"]}"
}
