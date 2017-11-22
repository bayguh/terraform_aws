# AWSで使用するterraformコードのテンプレート

terraform version: 0.11.0


## 各環境の構築

1.各環境のterraform.tfstateファイルをS3で管理します。<br />
  S3で管理用のバケットを作成し、tasks以下の各環境ディレクトリ以下にある`backend.tf`にパスを記載します。

2.terraformでアクセスするためのkeyを取得し、「keys/access.key」「keys/secret.key」に配置します。

(3.) provisionersを設定しているmoduleではssh接続が必要です。<br />
     対象のmoduleを使用する場合ssh鍵を登録し、「keys/ssh/access_key」に配置します。(ec2-user)<br />

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
│   │   └── access_key
│   └── ssl
├── modules
│   ├── eip
│   │   └── eip.tf
│   ├── instance
│   │   └── instance.tf
│   ├── instance_add_ebs
│   │   └── instance_add_ebs.tf
│   ├── internet_gateway
│   │   └── internet_gateway.tf
│   ├── route_table
│   │   └── route_table.tf
│   ├── route_table_association
│   │   └── route_table_association.tf
│   ├── s3_bucket
│   │   └── s3_bucket.tf
│   ├── s3_bucket_lifecycle_days
│   │   └── s3_bucket_lifecycle_days.tf
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
│   │   └── terraform_setup.sh
│   └── disk_partition
│       └── disk_partition.sh
├── tasks
│   ├── instance
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── s3
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── terraform.tfstate
│   │   ├── terraform.tfstate.backup
│   │   └── terraform.tfvars
│   ├── security_group
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   └── vpc
│       ├── backend.tf
│       ├── main.tf
│       └── terraform.tfvars
└── terraform_execute.sh
```
