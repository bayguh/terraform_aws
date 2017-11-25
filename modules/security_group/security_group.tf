variable "aws_security_group_variables" {
    type        = "map"
    description = "Security Group変数"

    default = {
      name   = ""
      vpc_id = ""
    }
}

/**
 * Security Group作成
 * https://www.terraform.io/docs/providers/aws/r/security_group.html
 */
resource "aws_security_group" "security_group" {
  name   = "${var.aws_security_group_variables["name"]}"
  vpc_id = "${var.aws_security_group_variables["vpc_id"]}"

  tags {
    Name = "${var.aws_security_group_variables["name"]}"
  }
}

output "security_group_id" {
    value = "${aws_security_group.security_group.id}"
}
