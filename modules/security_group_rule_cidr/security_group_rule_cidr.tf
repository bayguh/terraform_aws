variable "aws_security_group_rule_variables" {
    type        = "map"
    description = "Security Group Rule変数"

    default = {
      type              = ""
      from_port         = ""
      to_port           = ""
      protocol          = ""
      security_group_id = ""
    }
}

variable "cidr_blocks" {
  type    = "list"
  default = []
}

/**
 * Internet Gateway Rule作成
 * https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
 */
resource "aws_security_group_rule" "security_group_rule" {
  type              = "${var.aws_security_group_rule_variables["type"]}"
  from_port         = "${var.aws_security_group_rule_variables["from_port"]}"
  to_port           = "${var.aws_security_group_rule_variables["to_port"]}"
  protocol          = "${var.aws_security_group_rule_variables["protocol"]}"
  cidr_blocks       = "${var.cidr_blocks}"
  security_group_id = "${var.aws_security_group_rule_variables["security_group_id"]}"
}

output "security_group_rule_id" {
    value = "${aws_security_group_rule.security_group_rule.id}"
}
