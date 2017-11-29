variable "aws_vpc_dhcp_options_variables" {
    type        = "map"
    description = "dhcp options変数"

    default = {
      name        = ""
      domain_name = ""
    }
}

variable "domain_name_servers" {
  type    = "list"
  default = []
}

/**
 * dhcp options作成
 * https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options.html
 */
resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name         = "${var.aws_vpc_dhcp_options_variables["domain_name"]}"
  domain_name_servers = "${var.domain_name_servers}"

  tags {
    Name = "${var.aws_vpc_dhcp_options_variables["name"]}"
  }
}

output "dhcp_options_ip" {
    value = "${aws_vpc_dhcp_options.dhcp_options.id}"
}
