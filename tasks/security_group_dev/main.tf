variable "env" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.env == "prd" ? "${var.project_name}-vpc" : "${var.project_name}-${var.env}-vpc"}"]
  }
}

data "aws_security_group" "terraform" {
  filter {
    name   = "tag:Name"
    values = ["${var.env == "prd" ? "${var.project_name}-security-group-terraform" : "${var.project_name}-${var.env}-security-group-terraform"}"]
  }
}

/**
 * モジュール読み込み
 * https://www.terraform.io/docs/configuration/modules.html
 */

# セキュリティーグループ設定------------------------------------------------

# 共通のセキュリティーグループ---------------------------

module "security_group_common" {
  source = "../../modules/security_group"

  aws_security_group_variables {
    name   = "${var.env == "prd" ? "${var.project_name}-security-group-common" : "${var.project_name}-${var.env}-security-group-common"}"
    vpc_id = "${data.aws_vpc.vpc.id}"
  }
}

# internetアクセス
module "all_allow_tcp" {
  source = "../../modules/security_group_rule_cidr"

  aws_security_group_rule_variables {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    security_group_id = "${module.security_group_common.security_group_id}"
  }

  cidr_blocks = ["0.0.0.0/0"]
}

# 全サーバからicmpアクセス
module "allow_all_icmp" {
  source = "../../modules/security_group_rule_cidr"

  aws_security_group_rule_variables {
    type              = "ingress"
    from_port         = "-1"
    to_port           = "-1"
    protocol          = "icmp"
    security_group_id = "${module.security_group_common.security_group_id}"
  }

  cidr_blocks = ["0.0.0.0/0"]
}

# terraformから全サーバへのssh
module "all_allow_terraform_ssh" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = "${data.aws_security_group.terraform.id}"
    security_group_id        = "${module.security_group_common.security_group_id}"
  }
}

# ansibleから全サーバへのssh
module "all_allow_ansible_ssh" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = "${module.security_group_ansible.security_group_id}"
    security_group_id        = "${module.security_group_common.security_group_id}"
  }
}

# bastionから全サーバへのssh
module "all_allow_bastion_ssh" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = "${module.security_group_bastion.security_group_id}"
    security_group_id        = "${module.security_group_common.security_group_id}"
  }
}

# 全サーバへのconsul 8300-8302
module "all_allow_consul_8300-8302" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 8300
    to_port                  = 8302
    protocol                 = "tcp"
    source_security_group_id = "${module.security_group_common.security_group_id}"
    security_group_id        = "${module.security_group_common.security_group_id}"
  }
}

# 全サーバへのconsul 8400
module "all_allow_consul_8400" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 8400
    to_port                  = 8400
    protocol                 = "tcp"
    source_security_group_id = "${module.security_group_common.security_group_id}"
    security_group_id        = "${module.security_group_common.security_group_id}"
  }
}

# 全サーバへのconsul 8500
module "all_allow_consul_8500" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 8500
    to_port                  = 8500
    protocol                 = "tcp"
    source_security_group_id = "${module.security_group_common.security_group_id}"
    security_group_id        = "${module.security_group_common.security_group_id}"
  }
}

# 全サーバへのconsul 8600
module "all_allow_consul_8600" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 8600
    to_port                  = 8600
    protocol                 = "tcp"
    source_security_group_id = "${module.security_group_common.security_group_id}"
    security_group_id        = "${module.security_group_common.security_group_id}"
  }
}

# 全サーバへのconsul udp 8301-8302
module "all_allow_consul_udp_8301-8302" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 8301
    to_port                  = 8302
    protocol                 = "udp"
    source_security_group_id = "${module.security_group_common.security_group_id}"
    security_group_id        = "${module.security_group_common.security_group_id}"
  }
}

# 全サーバへのconsul udp 8600
module "all_allow_consul_udp_8600" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 8600
    to_port                  = 8600
    protocol                 = "udp"
    source_security_group_id = "${module.security_group_common.security_group_id}"
    security_group_id        = "${module.security_group_common.security_group_id}"
  }
}

# -------------------------------------------------

# http lbのセキュリティーグループ----------------------

module "security_group_lb_http" {
  source = "../../modules/security_group"

  aws_security_group_variables {
    name   = "${var.env == "prd" ? "${var.project_name}-security-group-lb-http" : "${var.project_name}-${var.env}-security-group-lb-http"}"
    vpc_id = "${data.aws_vpc.vpc.id}"
  }
}

# internetアクセス
module "all_allow_lb_http_tcp" {
  source = "../../modules/security_group_rule_cidr"

  aws_security_group_rule_variables {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    security_group_id = "${module.security_group_lb_http.security_group_id}"
  }

  cidr_blocks = ["0.0.0.0/0"]
}

# httpアクセス
module "allow_all_http" {
  source = "../../modules/security_group_rule_cidr"

  aws_security_group_rule_variables {
    type              = "ingress"
    from_port         = "80"
    to_port           = "80"
    protocol          = "TCP"
    security_group_id = "${module.security_group_lb_http.security_group_id}"
  }

  cidr_blocks = ["0.0.0.0/0"]
}

# -------------------------------------------------

# https lbのセキュリティーグループ---------------------

module "security_group_lb_https" {
  source = "../../modules/security_group"

  aws_security_group_variables {
    name   = "${var.env == "prd" ? "${var.project_name}-security-group-lb-https" : "${var.project_name}-${var.env}-security-group-lb-https"}"
    vpc_id = "${data.aws_vpc.vpc.id}"
  }
}

# internetアクセス
module "all_allow_lb_https_tcp" {
  source = "../../modules/security_group_rule_cidr"

  aws_security_group_rule_variables {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    security_group_id = "${module.security_group_lb_https.security_group_id}"
  }

  cidr_blocks = ["0.0.0.0/0"]
}

# httpsアクセス
module "allow_all_https" {
  source = "../../modules/security_group_rule_cidr"

  aws_security_group_rule_variables {
    type              = "ingress"
    from_port         = "443"
    to_port           = "443"
    protocol          = "TCP"
    security_group_id = "${module.security_group_lb_https.security_group_id}"
  }

  cidr_blocks = ["0.0.0.0/0"]
}

# -------------------------------------------------


# terraformのセキュリティーグループ-------------------

# bastionからterraformへのmysql
module "terraform_allow_bastion_ssh" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = "${module.security_group_bastion.security_group_id}"
    security_group_id        = "${data.aws_security_group.terraform.id}"
  }
}

# -------------------------------------------------

# ansibleのセキュリティーグループ-----------------------

# ansible セキュリティーグループ
module "security_group_ansible" {
  source = "../../modules/security_group"

  aws_security_group_variables {
    name   = "${var.env == "prd" ? "${var.project_name}-security-group-ansible" : "${var.project_name}-${var.env}-security-group-ansible"}"
    vpc_id = "${data.aws_vpc.vpc.id}"
  }
}

# -------------------------------------------------

# bastionのセキュリティーグループ------------------------

# bastion セキュリティーグループ
module "security_group_bastion" {
  source = "../../modules/security_group"

  aws_security_group_variables {
    name   = "${var.env == "prd" ? "${var.project_name}-security-group-bastion" : "${var.project_name}-${var.env}-security-group-bastion"}"
    vpc_id = "${data.aws_vpc.vpc.id}"
  }
}

# bastionへのssh
module "bastion_allow_all_ssh" {
  source = "../../modules/security_group_rule_cidr"

  aws_security_group_rule_variables {
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    security_group_id = "${module.security_group_bastion.security_group_id}"
  }

  cidr_blocks = ["0.0.0.0/0"]
}

# -------------------------------------------------

# consulのセキュリティーグループ------------------------

# consul セキュリティーグループ
module "security_group_consul" {
  source = "../../modules/security_group"

  aws_security_group_variables {
    name   = "${var.env == "prd" ? "${var.project_name}-security-group-consul" : "${var.project_name}-${var.env}-security-group-consul"}"
    vpc_id = "${data.aws_vpc.vpc.id}"
  }
}

# -------------------------------------------------

# webのセキュリティーグループ---------------------------

# web セキュリティーグループ
module "security_group_web" {
  source = "../../modules/security_group"

  aws_security_group_variables {
    name   = "${var.env == "prd" ? "${var.project_name}-security-group-web" : "${var.project_name}-${var.env}-security-group-web"}"
    vpc_id = "${data.aws_vpc.vpc.id}"
  }
}

# webへのhttp
module "all_allow_web_http" {
  source = "../../modules/security_group_rule_cidr"

  aws_security_group_rule_variables {
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    security_group_id = "${module.security_group_web.security_group_id}"
  }

  cidr_blocks = ["0.0.0.0/0"]
}

# -------------------------------------------------

# dbのセキュリティーグループ----------------------------

# db セキュリティーグループ
module "security_group_db" {
  source = "../../modules/security_group"

  aws_security_group_variables {
    name   = "${var.env == "prd" ? "${var.project_name}-security-group-db" : "${var.project_name}-${var.env}-security-group-db"}"
    vpc_id = "${data.aws_vpc.vpc.id}"
  }
}

# webからdbへのmysql
module "db_allow_web_mysql" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    source_security_group_id = "${module.security_group_web.security_group_id}"
    security_group_id        = "${module.security_group_db.security_group_id}"
  }
}

# -------------------------------------------------
