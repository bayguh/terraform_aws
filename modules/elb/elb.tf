variable "aws_elb_variables" {
    type = "map"
    description = "elb変数"

    default = {
      name                        = ""
      cross_zone_load_balancing   = ""
      idle_timeout                = ""
      connection_draining         = ""
      connection_draining_timeout = ""
      access_logs_bucket          = ""
      access_logs_bucket_prefix   = ""
      access_logs_interval        = ""
      access_logs_enabled         = ""
      instance_port               = ""
      instance_protocol           = ""
      lb_port                     = ""
      lb_protocol                 = ""
      healthy_threshold           = ""
      unhealthy_threshold         = ""
      timeout                     = ""
      target                      = ""
      interval                    = ""
    }
}

variable "security_groups" {
  type = "list"
  default = []
}

variable "instances" {
  type = "list"
  default = []
}

/**
 * elb作成(Classic Load Balancer)
 * https://www.terraform.io/docs/providers/aws/r/elb.html
 */
resource "aws_elb" "elb" {
  name                        = "${var.aws_elb_variables["name"]}"
  security_groups             = "${var.security_groups}"
  instances                   = "${var.instances}"
  cross_zone_load_balancing   = "${var.aws_elb_variables["cross_zone_load_balancing"]}"
  idle_timeout                = "${var.aws_elb_variables["idle_timeout"]}"
  connection_draining         = "${var.aws_elb_variables["connection_draining"]}"
  connection_draining_timeout = "${var.aws_elb_variables["connection_draining_timeout"]}"

  access_logs {
    bucket        = "${var.aws_elb_variables["access_logs_bucket"]}"
    bucket_prefix = "${var.aws_elb_variables["access_logs_bucket_prefix"]}"
    interval      = "${var.aws_elb_variables["access_logs_interval"]}"
    enabled       = "${var.aws_elb_variables["access_logs_enabled"]}"
  }

  listener {
    instance_port     = "${var.aws_elb_variables["instance_port"]}"
    instance_protocol = "${var.aws_elb_variables["instance_protocol"]}"
    lb_port           = "${var.aws_elb_variables["lb_port"]}"
    lb_protocol       = "${var.aws_elb_variables["lb_protocol"]}"
  }

  health_check {
    healthy_threshold   = "${var.aws_elb_variables["healthy_threshold"]}"
    unhealthy_threshold = "${var.aws_elb_variables["unhealthy_threshold"]}"
    timeout             = "${var.aws_elb_variables["timeout"]}"
    target              = "${var.aws_elb_variables["target"]}"
    interval            = "${var.aws_elb_variables["interval"]}"
  }

  tags {
    Name = "${var.aws_elb_variables["name"]}"
  }
}

output "elb_id" {
  value = "${aws_elb.elb.id}"
}
