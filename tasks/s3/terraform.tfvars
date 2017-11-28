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

# LBログ用バケット
bucket_lb_log_settings {
  bucket = "lb-log-bucket"
  region = "ap-northeast-1"
  acl    = "private"
  days   = 30
  env    = "shd"
}

# LBログ用バケットポリシー
bucket_policy_lb_log =<<POLICY
{
  "Version": "2012-10-17",
  "Id": "LBLOGBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "LOGWRITE",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::582318560864:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::bayguh-lb-log-bucket/*"
    }
  ]
}
POLICY
