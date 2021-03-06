variable "aws_lb_variables" {
    type        = "map"
    description = "network lb変数"

    default = {
      name                       = ""
      internal                   = ""
      enable_deletion_protection = ""
      idle_timeout               = ""
      subnet_id                  = ""
      allocation_id              = ""
    }
}

/**
 * lb作成(Network Load Balancer)
 * https://www.terraform.io/docs/providers/aws/r/lb.html
 */
resource "aws_lb" "network_lb" {
  name                       = "${var.aws_lb_variables["name"]}"
  internal                   = "${var.aws_lb_variables["internal"]}"
  load_balancer_type         = "network"
  enable_deletion_protection = "${var.aws_lb_variables["enable_deletion_protection"]}"
  idle_timeout               = "${var.aws_lb_variables["idle_timeout"]}"

  subnet_mapping {
    subnet_id     = "${var.aws_lb_variables["subnet_id"]}"
    allocation_id = "${var.aws_lb_variables["allocation_id"]}"
  }

  tags {
    Name = "${var.aws_lb_variables["name"]}"
  }
}

output "lb_id" {
  value = "${aws_lb.network_lb.id}"
}

output "lb_arn" {
  value = "${aws_lb.network_lb.arn}"
}
