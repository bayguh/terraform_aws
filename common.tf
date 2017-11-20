# 実行時に変数指定----------------------------
variable "access_key" {}
variable "secret_key" {}
# -----------------------------------------

# common.tfvarsで変数指定--------------------
variable "default_region" {}
variable "project_name" {}

variable "terraform_ip" { type = "list" }
# -----------------------------------------

/**
 * terraform対応バージョン
 * https://www.terraform.io/docs/configuration/terraform.html
 */
terraform {
  required_version = "= 0.11.0"
}
