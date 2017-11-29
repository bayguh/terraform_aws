variable "aws_route53_zone_variables" {
    type        = "map"
    description = "route53 zone変数"

    default = {
      name   = ""
      vpc_id = ""
    }
}

/**
 * route53 zone 作成
 * https://www.terraform.io/docs/providers/aws/r/route53_zone.html
 */
resource "aws_route53_zone" "route53_zone" {
  name   = "${var.aws_route53_zone_variables["name"]}"
  vpc_id = "${var.aws_route53_zone_variables["vpc_id"]}"

}

output "zone_id" {
    value = "${aws_route53_zone.route53_zone.zone_id}"
}

output "zone_name" {
    value = "${aws_route53_zone.route53_zone.name}"
}
