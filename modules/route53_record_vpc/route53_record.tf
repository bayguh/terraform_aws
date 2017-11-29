variable "aws_route53_record_variables" {
    type         = "map"
    description = "route53 record変数"

    default = {
      count   = ""
      name    = ""
      zone_id = ""
      type    = ""
      ttl     = ""
    }
}

variable "private_ips" {
  type    = "list"
  default = []
}

/**
 * route53 record 作成
 * https://www.terraform.io/docs/providers/aws/r/route53_record.html
 */
resource "aws_route53_record" "route53_record" {
  count   = "${var.aws_route53_record_variables["count"]}"
  name    = "${format(var.aws_route53_record_variables["name"], count.index+1)}"
  zone_id = "${var.aws_route53_record_variables["zone_id"]}"
  type    = "${var.aws_route53_record_variables["type"]}"
  ttl     = "${var.aws_route53_record_variables["ttl"]}"

  records = ["${element(var.private_ips, count.index)}"]
}
