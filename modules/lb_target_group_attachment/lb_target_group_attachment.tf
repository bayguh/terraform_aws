variable "aws_lb_target_group_attachment_variables" {
    type        = "map"
    description = "lb target group attachment変数"

    default = {
      count            = ""
      target_group_arn = ""
      port             = ""
    }
}

variable "target_ids" {
  type    = "list"
  default = []
}

/**
 * lb target group attachment作成
 * https://www.terraform.io/docs/providers/aws/r/lb_target_group_attachment.html
 */
resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  count            = "${var.aws_lb_target_group_attachment_variables["count"]}"
  target_group_arn = "${var.aws_lb_target_group_attachment_variables["target_group_arn"]}"
  target_id        = "${element(var.target_ids, count.index)}"
  port             = "${var.aws_lb_target_group_attachment_variables["port"]}"

  lifecycle {
    ignore_changes = ["target_id"]
  }
}

output "lb_target_group_attachment_ids" {
  value = "${join(",", aws_lb_target_group_attachment.lb_target_group_attachment.*.id)}"
}

