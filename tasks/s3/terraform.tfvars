# region
# [us-east-1, us-east-2, us-west-1, us-west-2, ca-central-1, eu-west-1, eu-central-1, eu-west-2]
# [ap-northeast-1, ap-northeast-2, ap-southeast-1, ap-southeast-2, ap-south-1, sa-east-1]

# 通常バケット設定
bucket_default_settings {
  bucket = "default-bucket"
  region = "ap-northeast-1"
  acl    = "private"
  env    = "shd"
}

// バックアップ用バケット設定
bucket_backup_settings {
  bucket = "backup-bucket"
  region = "ap-northeast-1"
  acl    = "private"
  days   = 30
  env    = "shd"
}
