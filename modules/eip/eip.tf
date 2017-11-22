variable "aws_eip_variables" {
    type = "map"
    description = "VPC変数"

    default = {
      count    = ""
      vpc      = ""
    }
}

variable "instances" {
  type = "list"
  default = []
}

/**
 * EIP作成
 * https://www.terraform.io/docs/providers/aws/r/eip.html
 */
resource "aws_eip" "eip" {
  count    = "${var.aws_eip_variables["count"]}"
  instance = "${element(var.instances, count.index)}"
  vpc      = "${var.aws_eip_variables["vpc"]}"
}

output "eip_ids" {
    value = "${join(",", aws_eip.eip.*.id)}"
}

output "public_ips" {
    value = "${aws_eip.eip.*.public_ip}"
}
