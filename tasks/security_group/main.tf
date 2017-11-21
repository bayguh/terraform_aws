data "aws_vpc" "selected" {
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-vpc"]
  }
}

/**
 * モジュール読み込み
 * https://www.terraform.io/docs/configuration/modules.html
 */

# セキュリティーグループ設定-------------------------------------------

# webのセキュリティーグループ---------------------------

# web セキュリティーグループ
module "security_group_web" {
  source = "../../modules/security_group"

  aws_security_group_variables {
    name   = "${var.project_name}-security-group-web"
    vpc_id = "${data.aws_vpc.selected.id}"
  }
}

# ladderからwebへのssh
module "web_allow_ladder_ssh" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = "${module.security_group_ladder.security_group_id}"
    security_group_id        = "${module.security_group_web.security_group_id}"
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

# internetアクセス
module "web_allow_all_tcp" {
  source = "../../modules/security_group_rule_cidr"

  aws_security_group_rule_variables {
    type              = "egress"
    from_port         = 0
    to_port           = 65535
    protocol          = "tcp"
    security_group_id = "${module.security_group_web.security_group_id}"
  }

  cidr_blocks = ["0.0.0.0/0"]
}

# -------------------------------------------------

# dbのセキュリティーグループ----------------------------

# DB セキュリティーグループ
module "security_group_db" {
  source = "../../modules/security_group"

  aws_security_group_variables {
    name   = "${var.project_name}-security-group-db"
    vpc_id = "${data.aws_vpc.selected.id}"
  }
}

# ladderからdbへのssh
module "db_allow_ladder_ssh" {
  source = "../../modules/security_group_rule"

  aws_security_group_rule_variables {
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    source_security_group_id = "${module.security_group_ladder.security_group_id}"
    security_group_id        = "${module.security_group_db.security_group_id}"
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

# ladderのセキュリティーグループ------------------------

# ladder セキュリティーグループ
module "security_group_ladder" {
  source = "../../modules/security_group"

  aws_security_group_variables {
    name   = "${var.project_name}-security-group-ladder"
    vpc_id = "${data.aws_vpc.selected.id}"
  }
}

# ladderへのssh
module "ladder_allow_all_ssh" {
  source = "../../modules/security_group_rule_cidr"

  aws_security_group_rule_variables {
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    security_group_id = "${module.security_group_ladder.security_group_id}"
  }

  cidr_blocks = ["0.0.0.0/0"]
}

# -------------------------------------------------
