variable "dns_suffix" {}
variable "ttl" {}

variable "records_dev_web_setting" { type = "map" }
variable "records_stg_web_setting" { type = "map" }

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
    name    = "${var.records_dev_web_setting["env"] == "prd" ? "web.${var.dns_suffix}" : "${var.records_dev_web_setting["env"]}-web.${var.dns_suffix}"}"
    zone_id = "${module.route53_zone.zone_id}"
    type    = "${var.records_dev_web_setting["type"]}"
    ttl     = "${var.ttl}"
  }

  records = ["${var.records_dev_web_setting["record"]}"]
}

# web用 route53 record stg
module "route53_record_stg_web" {
  source = "../../modules/route53_record"

  aws_route53_record_variables {
    name    = "${var.records_dev_web_setting["env"] == "prd" ? "web.${var.dns_suffix}" : "${var.records_stg_web_setting["env"]}-web.${var.dns_suffix}"}"
    zone_id = "${module.route53_zone.zone_id}"
    type    = "${var.records_stg_web_setting["type"]}"
    ttl     = "${var.ttl}"
  }

  records = ["${var.records_stg_web_setting["record"]}"]
}
