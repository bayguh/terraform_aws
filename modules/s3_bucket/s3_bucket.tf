variable "aws_s3_bucket_variables" {
    type        = "map"
    description = "バケット変数"

    default = {
      bucket = ""
      region = ""
      acl    = ""
      env    = ""
    }
}

/**
 * バケット作成
 * https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
 */
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.aws_s3_bucket_variables["bucket"]}"
  region = "${var.aws_s3_bucket_variables["region"]}"
  acl    = "${var.aws_s3_bucket_variables["acl"]}"

  tags {
    env = "${var.aws_s3_bucket_variables["env"]}"
  }
}
