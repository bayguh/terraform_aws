terraform {
  backend "s3" {
    bucket = "terraform-bayguh-tfstate"
    key    = "terraform_tfstate.d/security_group_dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
