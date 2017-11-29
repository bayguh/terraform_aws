variable "aws_vpc_dhcp_options_association_variables" {
    type        = "map"
    description = "dhcp options association変数"

    default = {
      vpc_id          = ""
      dhcp_options_id = ""
    }
}

/**
 * dhcp options association作成
 * https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options_association.html
 */
resource "aws_vpc_dhcp_options_association" "dhcp_options_association" {
  vpc_id          = "${var.aws_vpc_dhcp_options_association_variables["vpc_id"]}"
  dhcp_options_id = "${var.aws_vpc_dhcp_options_association_variables["dhcp_options_id"]}"
}
