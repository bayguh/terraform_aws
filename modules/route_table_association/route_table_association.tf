variable "aws_route_table_association_variables" {
    type        = "map"
    description = "Route Table Association変数"

    default = {
      count          = ""
      route_table_id = ""
    }
}

variable "subnet_ids" {
  type    = "list"
  default = []
}

/**
 * Route Table Association作成
 * https://www.terraform.io/docs/providers/aws/r/route_table_association.html
 */
resource "aws_route_table_association" "route_table_association" {
  count          = "${var.aws_route_table_association_variables["count"]}"
  subnet_id      = "${element(var.subnet_ids, count.index)}"
  route_table_id = "${var.aws_route_table_association_variables["route_table_id"]}"
}
