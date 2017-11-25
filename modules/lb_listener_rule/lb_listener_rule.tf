variable "aws_lb_listener_rule_variables" {
    type        = "map"
    description = "lb listener rule変数"

    default = {
      listener_arn     = ""
      priority         = ""
      target_group_arn = ""
      field            = ""
    }
}

variable "condition_values" {
  type    = "list"
  default = []
}

/**
 * lb listener rule作成
 * https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
 */
resource "aws_lb_listener_rule" "lb_listener_rule" {
  listener_arn = "${var.aws_lb_listener_rule_variables["listener_arn"]}"
  priority     = "${var.aws_lb_listener_rule_variables["priority"]}"

  action {
    target_group_arn = "${var.aws_lb_listener_rule_variables["target_group_arn"]}"
    type             = "forward"
  }

  condition {
    field  = "${var.aws_lb_listener_rule_variables["field"]}"
    values = "${var.condition_values}"
  }
}

output "lb_listener_rule_id" {
  value = "${aws_lb_listener_rule.lb_listener_rule.id}"
}

output "lb_listener_rule_arn" {
  value = "${aws_lb_listener_rule.lb_listener_rule.arn}"
}
