variable "aws_internet_gateway_variables" {
    type        = "map"
    description = "Internet Gateway変数"

    default = {
      name   = ""
      vpc_id = ""
    }
}

/**
 * Internet Gateway作成
 * https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
 */
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${var.aws_internet_gateway_variables["vpc_id"]}"

  tags {
    Name = "${var.aws_internet_gateway_variables["name"]}"
  }
}

output "internet_gateway_id" {
    value = "${aws_internet_gateway.internet_gateway.id}"
}
