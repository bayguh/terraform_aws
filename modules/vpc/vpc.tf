variable "aws_vpc_variables" {
    type        = "map"
    description = "VPC変数"

    default = {
      name                 = ""
      cidr_block           = ""
      instance_tenancy     = ""
      enable_dns_support   = ""
      enable_dns_hostnames = ""
    }
}

/**
 * VPC作成
 * https://www.terraform.io/docs/providers/aws/r/vpc.html
 */
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.aws_vpc_variables["cidr_block"]}"
  instance_tenancy     = "${var.aws_vpc_variables["instance_tenancy"]}"
  enable_dns_support   = "${var.aws_vpc_variables["enable_dns_support"]}"
  enable_dns_hostnames = "${var.aws_vpc_variables["enable_dns_hostnames"]}"

  tags {
    Name = "${var.aws_vpc_variables["name"]}"
  }
}

output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}
