variable "aws_nat_gateway_variables" {
    type = "map"
    description = "NAT Gateway変数"

    default = {
      name          = ""
      allocation_id = ""
      subnet_id     = ""
    }
}

/**
 * NAT Gateway作成
 * https://www.terraform.io/docs/providers/aws/r/nat_gateway.html
 */
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${var.aws_nat_gateway_variables["allocation_id"]}"
  subnet_id     = "${var.aws_nat_gateway_variables["subnet_id"]}"

  tags {
    Name = "${var.aws_nat_gateway_variables["name"]}"
  }
}

output "nat_gateway_id" {
  value = "${aws_nat_gateway.nat_gateway.id}"
}
