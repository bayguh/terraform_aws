variable "aws_lb_listener_variables" {
    type        = "map"
    description = "lb listener変数"

    default = {
      load_balancer_arn = ""
      port              = ""
      protocol          = ""
      target_group_arn  = ""
    }
}

/**
 * lb listener作成
 * https://www.terraform.io/docs/providers/aws/r/lb_listener.html
 */
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = "${var.aws_lb_listener_variables["load_balancer_arn"]}"
  port              = "${var.aws_lb_listener_variables["port"]}"
  protocol          = "${var.aws_lb_listener_variables["protocol"]}"

  default_action {
    target_group_arn = "${var.aws_lb_listener_variables["target_group_arn"]}"
    type             = "forward"
  }
}

output "lb_listener_id" {
  value = "${aws_lb_listener.lb_listener.id}"
}

output "lb_listener_arn" {
  value = "${aws_lb_listener.lb_listener.arn}"
}
