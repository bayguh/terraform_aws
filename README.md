# AWSで使用するterraformコードのテンプレート

terraform version: 0.11.0


## 各環境の構築

1.各環境のterraform.tfstateファイルをS3で管理します。<br />
  S3で管理用のバケットを作成し、tasks以下の各環境ディレクトリ以下にある`backend.tf`にパスを記載します。

2.terraformでアクセスするためのkeyを取得し、「keys/access.key」「keys/secret.key」に配置します。

(3.) provisionersを設定しているmoduleではssh接続が必要です。<br />
     対象のmoduleを使用する場合ssh鍵を登録し、「keys/ssh/access-key.pem」に配置します。(ec2-user)<br />

     ※ 現在の対象module: [instance_add_disk]
     ※ こちらを利用する際は別途ファイアーウォール設定が必要です。常に許可出来ない場合はterraform実行用サーバを用意し、そこからのFWルールを設定しておきましょう。

4.ssh証明書を登録する場合は 証明書:「keys/ssl/certificate.pem」中間証明書:「keys/ssl/chain_certificate.pem」プライベートキー:「keys/ssl/private.key」をそれぞれ配置して下さい。

5.プロジェクト毎の設定を`common.tfvars`に記載します。

6.各タスク毎の設定を各環境ディレクトリ以下にある`terraform.tfvars`に記載します。

7.実行はトップにある`terraform_execute.sh`を利用して実行します。

実行例:
```shell
./terraform_execute.sh plan s3
./terraform_execute.sh plan s3 upgrade
./terraform_execute.sh apply s3
./terraform_execute.sh destroy s3
```

## ネットワーク構成
下記を参考に本番と開発を分け(パターン4)、開発はVPCで分ける(パターン2-1)<br />

https://dev.classmethod.jp/cloud/aws/account-and-vpc-dividing-pattern/

## 実行順序
1. VPC作成
```
./terraform_execute.sh apply vpc[環境]
```

2. terraformサーバの作成
```
sh scripts/aws_setup/terraform_create.sh
```

(2.5)ここ以下からterraformサーバ上で実行
```
sh scripts/aws_setup/terraform_setup.sh user
sh scripts/aws_setup/terraform_setup.sh setup
sh scripts/aws_setup/terraform_setup.sh version
```

3. セキュリティーグループの作成
```
./terraform_execute.sh apply security_group[環境]
```

4. インスタンス作成
```
./terraform_execute.sh apply instance[環境]
```

## その他
・ terraformサーバの作成は「scripts/aws_setup/terraform_setup.sh」で行います。

## 現在のディレクトリ構造
```
├── README.md
├── common.tf
├── common.tfvars
├── keys
│   ├── access.key
│   ├── secret.key
│   ├── ssh
│   │   └── access-key.pem
│   └── ssl
├── modules
│   ├── dhcp_options
│   │   └── dhcp_options.tf
│   ├── dhcp_options_association
│   │   └── dhcp_options_association.tf
│   ├── eip
│   │   └── eip.tf
│   ├── eip_instance
│   │   └── eip.tf
│   ├── endpoint
│   │   └── endpoint.tf
│   ├── iam_server_certificate
│   │   └── iam_server_certificate.tf
│   ├── instance
│   │   └── instance.tf
│   ├── instance_add_ebs
│   │   └── instance_add_ebs.tf
│   ├── internet_gateway
│   │   └── internet_gateway.tf
│   ├── lb_application
│   │   └── lb.tf
│   ├── lb_application_target_group
│   │   └── lb_target_group.tf
│   ├── lb_classic
│   │   └── elb.tf
│   ├── lb_listener
│   │   └── lb_listener.tf
│   ├── lb_listener_rule
│   │   └── lb_listener_rule.tf
│   ├── lb_listener_ssl
│   │   └── lb_listener.tf
│   ├── lb_network
│   │   └── lb.tf
│   ├── lb_network_target_group
│   │   └── lb_target_group.tf
│   ├── lb_target_group_attachment
│   │   └── lb_target_group_attachment.tf
│   ├── nat_gateway
│   │   └── nat_gateway.tf
│   ├── route53_record
│   │   └── route53_record.tf
│   ├── route53_record_vpc
│   │   └── route53_record.tf
│   ├── route53_zone
│   │   └── route53_zone.tf
│   ├── route53_zone_vpc
│   │   └── route53_zone.tf
│   ├── route_table
│   │   └── route_table.tf
│   ├── route_table_association
│   │   └── route_table_association.tf
│   ├── route_table_nat_gateway
│   │   └── route_table_nat_gateway.tf
│   ├── s3_bucket
│   │   └── s3_bucket.tf
│   ├── s3_bucket_lifecycle_days
│   │   └── s3_bucket_lifecycle_days.tf
│   ├── s3_bucket_policy
│   │   └── s3_bucket_policy.tf
│   ├── security_group
│   │   └── security_group.tf
│   ├── security_group_rule
│   │   └── security_group_rule.tf
│   ├── security_group_rule_cidr
│   │   └── security_group_rule_cidr.tf
│   ├── subnet
│   │   └── subnet.tf
│   └── vpc
│       └── vpc.tf
├── provider.tf
├── scripts
│   ├── aws_setup
│   │   ├── terraform_create.sh
│   │   └── terraform_setup.sh
│   ├── disk_partition
│   │   └── disk_partition.sh
│   └── update_hostname
│       └── update_hostname.sh
├── tasks
│   ├── http_loadbalancer_dev
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── https_loadbalancer_dev
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── instance_dev
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── network_loadbalancer_dev
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── route53
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── s3
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── security_group_dev
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── vpc_dev
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── vpc_shd
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   └── vpc_stg
│       ├── backend.tf
│       ├── main.tf
│       └── terraform.tfvars
└── terraform_execute.sh
```
