variable "env" {}

variable "instance_ansible_settings" { type = "map" }
variable "instance_web_settings" { type = "map" }
variable "instance_db_settings" { type = "map" }
variable "instance_ladder_settings" { type = "map" }
variable "instance_consul_settings" { type = "map" }

# vpc subnet読み込み -------------------------------------

data "aws_vpc" "selected" {
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-vpc"]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags {
    Type = "public"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags {
    Type = "private"
  }
}

# ------------------------------------------------------

# security_group読み込み ---------------------------------

data "aws_security_group" "common" {
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-security-group-common"]
  }
}

data "aws_security_group" "ansible" {
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-security-group-ansible"]
  }
}

data "aws_security_group" "web" {
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-security-group-web"]
  }
}

data "aws_security_group" "db" {
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-security-group-db"]
  }
}

data "aws_security_group" "ladder" {
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-security-group-ladder"]
  }
}

data "aws_security_group" "consul" {
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-security-group-consul"]
  }
}

# ------------------------------------------------------

/**
 * モジュール読み込み
 * https://www.terraform.io/docs/configuration/modules.html
 */

# インスタンス設定-----------------------------------------

# ansible
module "instance_ansible" {
  source = "../../modules/instance"

  aws_instance_variables {
    count         = "${var.instance_ansible_settings["count"]}"
    name          = "${var.env == "prd" ? "ansible%04d" : "${var.env}-ansible%04d"}"
    ami           = "${var.instance_ansible_settings["ami"]}"
    instance_type = "${var.instance_ansible_settings["instance_type"]}"
    key_name      = "${var.instance_ansible_settings["key_name"]}"
    volume_type   = "${var.instance_ansible_settings["volume_type"]}"
    volume_size   = "${var.instance_ansible_settings["volume_size"]}"
  }

  vpc_security_group_ids = ["${data.aws_security_group.common.id}", "${data.aws_security_group.ansible.id}"]
  subnet_ids             = "${data.aws_subnet_ids.public.ids}"
}

module "eip_ansible" {
  source = "../../modules/eip"

  aws_eip_variables {
    count  = "${var.instance_ansible_settings["count"]}"
    vpc    = true
  }

  instances = ["${(split(",", module.instance_ansible.instance_ids))}"]
}

# web
module "instance_web" {
  source = "../../modules/instance"

  aws_instance_variables {
    count         = "${var.instance_web_settings["count"]}"
    name          = "${var.env == "prd" ? "web%04d" : "${var.env}-web%04d"}"
    ami           = "${var.instance_web_settings["ami"]}"
    instance_type = "${var.instance_web_settings["instance_type"]}"
    key_name      = "${var.instance_web_settings["key_name"]}"
    volume_type   = "${var.instance_web_settings["volume_type"]}"
    volume_size   = "${var.instance_web_settings["volume_size"]}"
  }

  vpc_security_group_ids = ["${data.aws_security_group.common.id}", "${data.aws_security_group.web.id}"]
  subnet_ids             = "${data.aws_subnet_ids.private.ids}"
}

# db
module "instance_db" {
  source = "../../modules/instance_add_ebs"

  aws_instance_variables {
    count                    = "${var.instance_db_settings["count"]}"
    name                     = "${var.env == "prd" ? "db%04d" : "${var.env}-db%04d"}"
    ami                      = "${var.instance_db_settings["ami"]}"
    instance_type            = "${var.instance_db_settings["instance_type"]}"
    key_name                 = "${var.instance_db_settings["key_name"]}"
    volume_type              = "${var.instance_db_settings["volume_type"]}"
    volume_size              = "${var.instance_db_settings["volume_size"]}"
    ebs_device_name          = "${var.instance_db_settings["ebs_device_name"]}"
    ebs_volume_type          = "${var.instance_db_settings["ebs_volume_type"]}"
    ebs_volume_size          = "${var.instance_db_settings["ebs_volume_size"]}"
    private_key              = "${var.instance_db_settings["private_key"]}"
    disk_partition_file_path = "${var.instance_db_settings["disk_partition_file_path"]}"
    mount_path               = "${var.instance_db_settings["mount_path"]}"
  }

  vpc_security_group_ids = ["${data.aws_security_group.common.id}", "${data.aws_security_group.db.id}"]
  subnet_ids             = "${data.aws_subnet_ids.private.ids}"
}

# ladder
module "instance_ladder" {
  source = "../../modules/instance"

  aws_instance_variables {
    count         = "${var.instance_ladder_settings["count"]}"
    name          = "${var.env == "prd" ? "ladder%04d" : "${var.env}-ladder%04d"}"
    ami           = "${var.instance_ladder_settings["ami"]}"
    instance_type = "${var.instance_ladder_settings["instance_type"]}"
    key_name      = "${var.instance_ladder_settings["key_name"]}"
    volume_type   = "${var.instance_ladder_settings["volume_type"]}"
    volume_size   = "${var.instance_ladder_settings["volume_size"]}"
  }

  vpc_security_group_ids = ["${data.aws_security_group.common.id}", "${data.aws_security_group.ladder.id}"]
  subnet_ids             = "${data.aws_subnet_ids.public.ids}"
}

module "eip_ladder" {
  source = "../../modules/eip"

  aws_eip_variables {
    count  = "${var.instance_ladder_settings["count"]}"
    vpc    = true
  }

  instances = ["${(split(",", module.instance_ladder.instance_ids))}"]
}

# consul
module "instance_consul" {
  source = "../../modules/instance"

  aws_instance_variables {
    count         = "${var.instance_consul_settings["count"]}"
    name          = "${var.env == "prd" ? "consul%04d" : "${var.env}-consul%04d"}"
    ami           = "${var.instance_consul_settings["ami"]}"
    instance_type = "${var.instance_consul_settings["instance_type"]}"
    key_name      = "${var.instance_consul_settings["key_name"]}"
    volume_type   = "${var.instance_consul_settings["volume_type"]}"
    volume_size   = "${var.instance_consul_settings["volume_size"]}"
  }

  vpc_security_group_ids = ["${data.aws_security_group.common.id}", "${data.aws_security_group.consul.id}"]
  subnet_ids             = "${data.aws_subnet_ids.private.ids}"
}
