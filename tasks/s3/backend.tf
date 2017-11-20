terraform {
  backend "s3" {
    bucket = "terraform-bayguh-tfstate"
    key    = "terraform_tfstate.d/s3/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
