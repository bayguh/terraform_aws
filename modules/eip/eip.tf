variable "aws_eip_variables" {
    type        = "map"
    description = "VPC変数"

    default = {
      vpc = ""
    }
}

/**
 * EIP作成
 * https://www.terraform.io/docs/providers/aws/r/eip.html
 */
resource "aws_eip" "eip" {
  vpc = "${var.aws_eip_variables["vpc"]}"
}

output "eip_id" {
    value = "${aws_eip.eip.id}"
}

output "public_ip" {
    value = "${aws_eip.eip.public_ip}"
}
