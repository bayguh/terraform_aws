// DNSサフィックス
dns_suffix = "bayguh.jp."

// デフォルトttl
ttl = "300"

# dnsレコード設定
records_dev_web_setting {
  env    = "dev"
  type   = "A"
  record = "111.111.111.111"
}
records_stg_web_setting {
  env    = "stg"
  type   = "A"
  record = "222.222.222.222"
}
