variable "dns_suffix" {}
variable "ttl" {}

variable "records_web_dev" {}
variable "records_web_stg" {}
variable "records_web_prd" {}

/**
 * モジュール読み込み
 * https://www.terraform.io/docs/configuration/modules.html
 */

# route53 設定-------------------------------------------

# route53 zone
module "route53_zone" {
  source = "../../modules/route53_zone"

  aws_route53_zone_variables {
    name = "${var.dns_suffix}"
  }
}

# web用 route53 record dev
module "route53_record_dev_web" {
  source = "../../modules/route53_record"

  aws_route53_record_variables {
    name    = "dev-web.${var.dns_suffix}"
    zone_id = "${module.route53_zone.zone_id}"
    type    = "A"
    ttl     = "${var.ttl}"
  }

  records = ["${var.records_web_dev}"]
}

# web用 route53 record stg
module "route53_record_stg_web" {
  source = "../../modules/route53_record"

  aws_route53_record_variables {
    name    =  "stg-web.${var.dns_suffix}"
    zone_id = "${module.route53_zone.zone_id}"
    type    = "A"
    ttl     = "${var.ttl}"
  }

  records = ["${var.records_web_stg}"]
}

# web用 route53 record prd
module "route53_record_prd_web" {
  source = "../../modules/route53_record"

  aws_route53_record_variables {
    name    = "prd-web.${var.dns_suffix}"
    zone_id = "${module.route53_zone.zone_id}"
    type    = "A"
    ttl     = "${var.ttl}"
  }

  records = ["${var.records_web_prd}"]
}
