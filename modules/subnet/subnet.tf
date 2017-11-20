variable "aws_subnet_variables" {
    type = "map"
    description = "subnet変数"

    default = {
      name              = ""
      vpc_id            = ""
      cidr_block        = ""
      availability_zone = ""
    }
}

/**
 * subnet作成
 * https://www.terraform.io/docs/providers/aws/r/subnet.html
 */
resource "aws_subnet" "subnet" {
  vpc_id                  = "${var.aws_subnet_variables["vpc_id"]}"
  cidr_block              = "${var.aws_subnet_variables["cidr_block"]}"
  availability_zone       = "${var.aws_subnet_variables["availability_zone"]}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.aws_subnet_variables["name"]}"
  }
}

output "subnet_id" {
    value = "${aws_subnet.subnet.id}"
}
