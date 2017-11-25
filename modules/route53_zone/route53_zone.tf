variable "aws_route53_zone_variables" {
    type        = "map"
    description = "route53 zone変数"

    default = {
      name = ""
    }
}

/**
 * route53 zone 作成
 * https://www.terraform.io/docs/providers/aws/r/route53_zone.html
 */
resource "aws_route53_zone" "route53_zone" {
  name = "${var.aws_route53_zone_variables["name"]}"

}

output "zone_id" {
    value = "${aws_route53_zone.route53_zone.zone_id}"
}
