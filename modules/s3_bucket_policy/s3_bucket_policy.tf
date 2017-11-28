variable "aws_s3_bucket_policy_variables" {
    type        = "map"
    description = "バケットポリシー変数"

    default = {
      bucket = ""
      policy = ""
    }
}

/**
 * バケットポリシー作成
 * https://www.terraform.io/docs/providers/aws/r/s3_bucket_policy.html
 */
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = "${var.aws_s3_bucket_policy_variables["bucket"]}"
  policy = "${var.aws_s3_bucket_policy_variables["policy"]}"
}
