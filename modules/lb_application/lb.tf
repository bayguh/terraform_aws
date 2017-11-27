variable "aws_lb_variables" {
    type        = "map"
    description = "application lb変数"

    default = {
      name                        = ""
      internal                    = ""
      enable_deletion_protection  = ""
      idle_timeout                = ""
      access_logs_bucket          = ""
      access_logs_bucket_prefix   = ""
      access_logs_enabled         = ""
    }
}

variable "security_groups" {
  type    = "list"
  default = []
}

variable "subnets" {
  type    = "list"
  default = []
}

/**
 * lb作成(Application Load Balancer)
 * https://www.terraform.io/docs/providers/aws/r/lb.html
 */
resource "aws_lb" "application_lb" {
  name                       = "${var.aws_lb_variables["name"]}"
  internal                   = "${var.aws_lb_variables["internal"]}"
  load_balancer_type         = "application"
  security_groups            = ["${var.security_groups}"]
  subnets                    = ["${var.subnets}"]
  enable_deletion_protection = "${var.aws_lb_variables["enable_deletion_protection"]}"
  idle_timeout               = "${var.aws_lb_variables["idle_timeout"]}"

  access_logs {
    bucket        = "${var.aws_lb_variables["access_logs_bucket"]}"
    prefix        = "${var.aws_lb_variables["access_logs_bucket_prefix"]}"
    enabled       = "${var.aws_lb_variables["access_logs_enabled"]}"
  }

  tags {
    Name = "${var.aws_lb_variables["name"]}"
  }
}

output "lb_id" {
  value = "${aws_lb.application_lb.id}"
}

output "lb_arn" {
  value = "${aws_lb.application_lb.arn}"
}

