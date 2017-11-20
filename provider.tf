/**
 * プロバイダー設定
 * https://www.terraform.io/docs/providers/aws/index.html
 */
provider "aws" {
  access_key = "${chomp(file(var.access_key))}"
  secret_key = "${chomp(file(var.secret_key))}"
  region     = "${var.default_region}"
}
