variable "aws_subnet_variables" {
    type        = "map"
    description = "subnet変数"

    default = {
      name   = ""
      vpc_id = ""
      type   = ""
    }
}

variable "cidr_blocks" {
  type    = "list"
  default = []
}

variable "availability_zones" {
  type    = "list"
  default = []
}

/**
 * subnet作成
 * https://www.terraform.io/docs/providers/aws/r/subnet.html
 */
resource "aws_subnet" "subnet" {
  count                   = "${length(var.cidr_blocks)}"
  vpc_id                  = "${var.aws_subnet_variables["vpc_id"]}"
  cidr_block              = "${element(var.cidr_blocks, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index%length(var.availability_zones))}"
  map_public_ip_on_launch = true

  tags {
    Name = "${format(var.aws_subnet_variables["name"], count.index+1)}"
    Type = "${var.aws_subnet_variables["type"]}"
  }
}

output "subnet_ids" {
  value = "${join(",", aws_subnet.subnet.*.id)}"
}
