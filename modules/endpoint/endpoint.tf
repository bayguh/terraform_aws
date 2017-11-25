variable "aws_vpc_endpoint_variables" {
    type        = "map"
    description = "endpoint変数"

    default = {
      vpc_id       = ""
      service_name = ""
    }
}

variable "route_table_ids" {
  type    = "list"
  default = []
}

/**
 * endpoint作成
 * https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html
 */
resource "aws_vpc_endpoint" "endpoint" {
  vpc_id          = "${var.aws_vpc_endpoint_variables["vpc_id"]}"
  service_name    = "${var.aws_vpc_endpoint_variables["service_name"]}"
  route_table_ids = ["${var.route_table_ids}"]
}

output "endpoint_id" {
    value = "${aws_vpc_endpoint.endpoint.id}"
}
