variable "aws_lb_target_group_variables" {
    type        = "map"
    description = "application lb target group変数"

    default = {
      name                       = ""
      port                       = ""
      protocol                   = ""
      vpc_id                     = ""
      deregistration_delay       = ""
      stickiness_type            = ""
      stickiness_cookie_duration = ""
      stickiness_enabled         = ""
      interval                   = ""
      path                       = ""
      port                       = ""
      protocol                   = ""
      timeout                    = ""
      healthy_threshold          = ""
      unhealthy_threshold        = ""
      matcher                    = ""
    }
}

/**
 * lb target group作成(Application Load Balancer)
 * https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
 */
resource "aws_lb_target_group" "application_lb_target_group" {
  name                 = "${var.aws_lb_variables["name"]}"
  port                 = "${var.aws_lb_variables["port"]}"
  protocol             = "${var.aws_lb_variables["protocol"]}"
  vpc_id               = "${var.aws_lb_variables["vpc_id"]}"
  deregistration_delay = "${var.aws_lb_variables["deregistration_delay"]}"

  stickiness {
    type            = "${var.aws_lb_variables["stickiness_type"]}"
    cookie_duration = "${var.aws_lb_variables["stickiness_cookie_duration"]}"
    enabled         = "${var.aws_lb_variables["stickiness_enabled"]}"
  }

  health_check {
    interval            = "${var.aws_lb_variables["interval"]}"
    path                = "${var.aws_lb_variables["path"]}"
    port                = "${var.aws_lb_variables["port"]}"
    protocol            = "${var.aws_lb_variables["protocol"]}"
    timeout             = "${var.aws_lb_variables["timeout"]}"
    healthy_threshold   = "${var.aws_lb_variables["healthy_threshold"]}"
    unhealthy_threshold = "${var.aws_lb_variables["unhealthy_threshold"]}"
    matcher             = "${var.aws_lb_variables["matcher"]}"
  }

  tags {
    Name = "${var.aws_lb_variables["name"]}"
  }
}

output "lb_target_group_id" {
  value = "${aws_lb_target_group.application_lb_target_group.id}"
}

output "lb_target_group_arn" {
  value = "${aws_lb_target_group.application_lb_target_group.arn}"
}
