variable "aws_route53_record_variables" {
    type         = "map"
    description = "route53 record変数"

    default = {
      name    = ""
      zone_id = ""
      type    = ""
      ttl     = ""
    }
}

variable "records" {
  type    = "list"
  default = []
}

/**
 * route53 record 作成
 * https://www.terraform.io/docs/providers/aws/r/route53_record.html
 */
resource "aws_route53_record" "oute53_record" {
  name    = "${var.aws_route53_record_variables["name"]}"
  zone_id = "${var.aws_route53_record_variables["zone_id"]}"
  type    = "${var.aws_route53_record_variables["type"]}"
  ttl     = "${var.aws_route53_record_variables["ttl"]}"
  records = "${var.records}"
}
