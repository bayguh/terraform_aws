variable "env" {}

variable "bucket_default_settings" { type = "map" }
variable "bucket_backup_settings" { type = "map" }

/**
 * モジュール読み込み
 * https://www.terraform.io/docs/configuration/modules.html
 */

# バケット設定-----------------------------------------

# 通常バケット
module "bucket_default" {
  source = "../../modules/s3_bucket"

  aws_s3_bucket_variables {
    bucket = "${var.bucket_default_settings["bucket"]}"
    region = "${var.bucket_default_settings["region"]}"
    acl    = "${var.bucket_default_settings["acl"]}"
    env    = "${var.env}"
  }
}

# バックアップ用バケット
module "bucket_backup" {
  source = "../../modules/s3_bucket_lifecycle_days"

  aws_s3_bucket_variables {
    bucket = "${var.bucket_backup_settings["bucket"]}"
    region = "${var.bucket_backup_settings["region"]}"
    acl    = "${var.bucket_backup_settings["acl"]}"
    days   = "${var.bucket_backup_settings["days"]}"
    env    = "${var.env}"
  }
}
