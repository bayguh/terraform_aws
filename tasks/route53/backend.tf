terraform {
  backend "s3" {
    bucket = "terraform-bayguh-tfstate"
    key    = "terraform_tfstate.d/route53/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
