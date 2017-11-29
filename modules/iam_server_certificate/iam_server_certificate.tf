variable "aws_iam_server_certificate_variables" {
    type        = "map"
    description = "iam server certificate変数"

    default = {
      name                   = ""
      certificate_body_path  = ""
      certificate_chain_path = ""
      private_key_path       = ""
    }
}

/**
 * iam server certificate作成
 * https://www.terraform.io/docs/providers/aws/r/iam_server_certificate.html
 */
resource "aws_iam_server_certificate" "iam_server_certificate" {
  name              = "${var.aws_iam_server_certificate_variables["name"]}"
  certificate_body  = "${file("${var.aws_iam_server_certificate_variables["certificate_body_path"]}")}"
  certificate_chain = "${file("${var.aws_iam_server_certificate_variables["certificate_chain_path"]}")}"
  private_key       = "${file("${var.aws_iam_server_certificate_variables["private_key_path"]}")}"

  lifecycle {
    create_before_destroy = true
  }
}

output "iam_server_certificate_id" {
    value = "${aws_iam_server_certificate.iam_server_certificate.id}"
}

output "iam_server_certificate_arn" {
    value = "${aws_iam_server_certificate.iam_server_certificate.arn}"
}
