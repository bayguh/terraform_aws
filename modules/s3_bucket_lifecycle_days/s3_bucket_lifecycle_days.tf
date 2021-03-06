variable "aws_s3_bucket_variables" {
    type        = "map"
    description = "バケット変数"

    default = {
      bucket = ""
      region = ""
      acl    = ""
      days   = ""
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

  lifecycle_rule {
    enabled = true

    expiration {
      days = "${var.aws_s3_bucket_variables["days"]}"
    }
  }

  tags {
    env = "${var.aws_s3_bucket_variables["env"]}"
  }
}

output "bucket_id" {
    value = "${aws_s3_bucket.bucket.id}"
}
