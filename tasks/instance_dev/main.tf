variable "env" {}
variable "ttl" {}

variable "instance_ansible_settings" { type = "map" }
variable "instance_web_settings" { type = "map" }
variable "instance_db_settings" { type = "map" }
variable "instance_bastion_settings" { type = "map" }
variable "instance_consul_settings" { type = "map" }

# vpc subnet読み込み -------------------------------------

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.env == "prd" ? "${var.project_name}-vpc" : "${var.project_name}-${var.env}-vpc"}"]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags {
    Type = "public"
  }
}

data "aws_subnet_ids" "private-common" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags {
    Type = "private-common"
  }
}

data "aws_subnet_ids" "web" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags {
    Type = "web"
  }
}

data "aws_subnet_ids" "db" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags {
    Type = "db"
  }
}

data "aws_subnet_ids" "cache" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags {
    Type = "cache"
  }
}

# ------------------------------------------------------

# security_group読み込み ---------------------------------

data "aws_security_group" "common" {
  filter {
    name   = "tag:Name"
    values = ["${var.env == "prd" ? "${var.project_name}-security-group-common" : "${var.project_name}-${var.env}-security-group-common"}"]
  }
}

data "aws_security_group" "ansible" {
  filter {
    name   = "tag:Name"
    values = ["${var.env == "prd" ? "${var.project_name}-security-group-ansible" : "${var.project_name}-${var.env}-security-group-ansible"}"]
  }
}

data "aws_security_group" "web" {
  filter {
    name   = "tag:Name"
    values = ["${var.env == "prd" ? "${var.project_name}-security-group-web" : "${var.project_name}-${var.env}-security-group-web"}"]
  }
}

data "aws_security_group" "db" {
  filter {
    name   = "tag:Name"
    values = ["${var.env == "prd" ? "${var.project_name}-security-group-db" : "${var.project_name}-${var.env}-security-group-db"}"]
  }
}

data "aws_security_group" "bastion" {
  filter {
    name   = "tag:Name"
    values = ["${var.env == "prd" ? "${var.project_name}-security-group-bastion" : "${var.project_name}-${var.env}-security-group-bastion"}"]
  }
}

data "aws_security_group" "consul" {
  filter {
    name   = "tag:Name"
    values = ["${var.env == "prd" ? "${var.project_name}-security-group-consul" : "${var.project_name}-${var.env}-security-group-consul"}"]
  }
}

# ------------------------------------------------------

# route53_zone読み込み -----------------------------------

data "aws_route53_zone" "route53_zone_internal" {
  name   = "${var.env == "prd" ? "${var.project_name}.internal." : "${var.project_name}-${var.env}.internal."}"
  vpc_id = "${data.aws_vpc.vpc.id}"
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
    count                       = "${var.instance_ansible_settings["count"]}"
    name                        = "${var.env == "prd" ? "${var.project_name}-${var.instance_ansible_settings["type"]}%04d" : "${var.project_name}-${var.env}-${var.instance_ansible_settings["type"]}%04d"}"
    ami                         = "${var.instance_ansible_settings["ami"]}"
    instance_type               = "${var.instance_ansible_settings["instance_type"]}"
    key_name                    = "${var.instance_ansible_settings["key_name"]}"
    associate_public_ip_address = "${var.instance_ansible_settings["associate_public_ip_address"]}"
    volume_type                 = "${var.instance_ansible_settings["volume_type"]}"
    volume_size                 = "${var.instance_ansible_settings["volume_size"]}"
    private_key                 = "${var.instance_ansible_settings["private_key"]}"
    update_hostname_file_path   = "${var.instance_ansible_settings["update_hostname_file_path"]}"
    type                        = "${var.instance_ansible_settings["type"]}"
  }

  vpc_security_group_ids = ["${data.aws_security_group.common.id}", "${data.aws_security_group.ansible.id}"]
  subnet_ids             = "${data.aws_subnet_ids.public.ids}"
}

module "eip_ansible" {
  source = "../../modules/eip_instance"

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
    count                       = "${var.instance_web_settings["count"]}"
    name                        = "${var.env == "prd" ? "${var.project_name}-${var.instance_web_settings["type"]}%04d" : "${var.project_name}-${var.env}-${var.instance_web_settings["type"]}%04d"}"
    ami                         = "${var.instance_web_settings["ami"]}"
    instance_type               = "${var.instance_web_settings["instance_type"]}"
    key_name                    = "${var.instance_web_settings["key_name"]}"
    associate_public_ip_address = "${var.instance_web_settings["associate_public_ip_address"]}"
    volume_type                 = "${var.instance_web_settings["volume_type"]}"
    volume_size                 = "${var.instance_web_settings["volume_size"]}"
    private_key                 = "${var.instance_web_settings["private_key"]}"
    update_hostname_file_path   = "${var.instance_web_settings["update_hostname_file_path"]}"
    type                        = "${var.instance_web_settings["type"]}"
  }

  vpc_security_group_ids = ["${data.aws_security_group.common.id}", "${data.aws_security_group.web.id}"]
  subnet_ids             = "${data.aws_subnet_ids.web.ids}"
}

# db
module "instance_db" {
  source = "../../modules/instance_add_ebs"

  aws_instance_variables {
    count                       = "${var.instance_db_settings["count"]}"
    name                        = "${var.env == "prd" ? "${var.project_name}-${var.instance_db_settings["type"]}%04d" : "${var.project_name}-${var.env}-${var.instance_db_settings["type"]}%04d"}"
    ami                         = "${var.instance_db_settings["ami"]}"
    instance_type               = "${var.instance_db_settings["instance_type"]}"
    key_name                    = "${var.instance_db_settings["key_name"]}"
    associate_public_ip_address = "${var.instance_db_settings["associate_public_ip_address"]}"
    volume_type                 = "${var.instance_db_settings["volume_type"]}"
    volume_size                 = "${var.instance_db_settings["volume_size"]}"
    ebs_device_name             = "${var.instance_db_settings["ebs_device_name"]}"
    ebs_volume_type             = "${var.instance_db_settings["ebs_volume_type"]}"
    ebs_volume_size             = "${var.instance_db_settings["ebs_volume_size"]}"
    private_key                 = "${var.instance_db_settings["private_key"]}"
    update_hostname_file_path   = "${var.instance_db_settings["update_hostname_file_path"]}"
    disk_partition_file_path    = "${var.instance_db_settings["disk_partition_file_path"]}"
    mount_path                  = "${var.instance_db_settings["mount_path"]}"
    type                        = "${var.instance_db_settings["type"]}"
  }

  vpc_security_group_ids = ["${data.aws_security_group.common.id}", "${data.aws_security_group.db.id}"]
  subnet_ids             = "${data.aws_subnet_ids.db.ids}"
}

# bastion
module "instance_bastion" {
  source = "../../modules/instance"

  aws_instance_variables {
    count                       = "${var.instance_bastion_settings["count"]}"
    name                        = "${var.env == "prd" ? "${var.project_name}-${var.instance_bastion_settings["type"]}%04d" : "${var.project_name}-${var.env}-${var.instance_bastion_settings["type"]}%04d"}"
    ami                         = "${var.instance_bastion_settings["ami"]}"
    instance_type               = "${var.instance_bastion_settings["instance_type"]}"
    key_name                    = "${var.instance_bastion_settings["key_name"]}"
    associate_public_ip_address = "${var.instance_bastion_settings["associate_public_ip_address"]}"
    volume_type                 = "${var.instance_bastion_settings["volume_type"]}"
    volume_size                 = "${var.instance_bastion_settings["volume_size"]}"
    private_key                 = "${var.instance_bastion_settings["private_key"]}"
    update_hostname_file_path   = "${var.instance_bastion_settings["update_hostname_file_path"]}"
    type                        = "${var.instance_bastion_settings["type"]}"
  }

  vpc_security_group_ids = ["${data.aws_security_group.common.id}", "${data.aws_security_group.bastion.id}"]
  subnet_ids             = "${data.aws_subnet_ids.public.ids}"
}

module "eip_bastion" {
  source = "../../modules/eip_instance"

  aws_eip_variables {
    count  = "${var.instance_bastion_settings["count"]}"
    vpc    = true
  }

  instances = ["${(split(",", module.instance_bastion.instance_ids))}"]
}

# consul
module "instance_consul" {
  source = "../../modules/instance"

  aws_instance_variables {
    count                       = "${var.instance_consul_settings["count"]}"
    name                        = "${var.env == "prd" ? "${var.project_name}-${var.instance_consul_settings["type"]}%04d" : "${var.project_name}-${var.env}-${var.instance_consul_settings["type"]}%04d"}"
    ami                         = "${var.instance_consul_settings["ami"]}"
    instance_type               = "${var.instance_consul_settings["instance_type"]}"
    key_name                    = "${var.instance_consul_settings["key_name"]}"
    associate_public_ip_address = "${var.instance_consul_settings["associate_public_ip_address"]}"
    volume_type                 = "${var.instance_consul_settings["volume_type"]}"
    volume_size                 = "${var.instance_consul_settings["volume_size"]}"
    private_key                 = "${var.instance_consul_settings["private_key"]}"
    update_hostname_file_path   = "${var.instance_consul_settings["update_hostname_file_path"]}"
    type                        = "${var.instance_consul_settings["type"]}"
  }

  vpc_security_group_ids = ["${data.aws_security_group.common.id}", "${data.aws_security_group.consul.id}"]
  subnet_ids             = "${data.aws_subnet_ids.private-common.ids}"
}

# ------------------------------------------------------

# host名解決(DNS設定)-------------------------------------

# ansible internal host名解決用 route53 record
module "route53_record_instance_ansible" {
  source = "../../modules/route53_record_vpc"

  aws_route53_record_variables {
    count   = "${var.instance_ansible_settings["count"]}"
    name    = "${var.env == "prd" ? "${var.project_name}-${var.instance_ansible_settings["type"]}%04d" : "${var.project_name}-${var.env}-${var.instance_ansible_settings["type"]}%04d"}"
    zone_id = "${data.aws_route53_zone.route53_zone_internal.zone_id}"
    type    = "A"
    ttl     = "${var.ttl}"
  }

  private_ips = ["${split(",", module.instance_ansible.instance_privete_ips)}"]
}

# web internal host名解決用 route53 record
module "route53_record_instance_web" {
  source = "../../modules/route53_record_vpc"

  aws_route53_record_variables {
    count   = "${var.instance_web_settings["count"]}"
    name    = "${var.env == "prd" ? "${var.project_name}-${var.instance_web_settings["type"]}%04d" : "${var.project_name}-${var.env}-${var.instance_web_settings["type"]}%04d"}"
    zone_id = "${data.aws_route53_zone.route53_zone_internal.zone_id}"
    type    = "A"
    ttl     = "${var.ttl}"
  }

  private_ips = ["${split(",", module.instance_web.instance_privete_ips)}"]
}

# db internal host名解決用 route53 record
module "route53_record_instance_db" {
  source = "../../modules/route53_record_vpc"

  aws_route53_record_variables {
    count   = "${var.instance_db_settings["count"]}"
    name    = "${var.env == "prd" ? "${var.project_name}-${var.instance_db_settings["type"]}%04d" : "${var.project_name}-${var.env}-${var.instance_db_settings["type"]}%04d"}"
    zone_id = "${data.aws_route53_zone.route53_zone_internal.zone_id}"
    type    = "A"
    ttl     = "${var.ttl}"
  }

  private_ips = ["${split(",", module.instance_db.instance_privete_ips)}"]
}

# bastion internal host名解決用 route53 record
module "route53_record_instance_bastion" {
  source = "../../modules/route53_record_vpc"

  aws_route53_record_variables {
    count   = "${var.instance_bastion_settings["count"]}"
    name    = "${var.env == "prd" ? "${var.project_name}-${var.instance_bastion_settings["type"]}%04d" : "${var.project_name}-${var.env}-${var.instance_bastion_settings["type"]}%04d"}"
    zone_id = "${data.aws_route53_zone.route53_zone_internal.zone_id}"
    type    = "A"
    ttl     = "${var.ttl}"
  }

  private_ips = ["${split(",", module.instance_bastion.instance_privete_ips)}"]
}

# consul internal host名解決用 route53 record
module "route53_record_instance_consul" {
  source = "../../modules/route53_record_vpc"

  aws_route53_record_variables {
    count   = "${var.instance_consul_settings["count"]}"
    name    = "${var.env == "prd" ? "${var.project_name}-${var.instance_consul_settings["type"]}%04d" : "${var.project_name}-${var.env}-${var.instance_consul_settings["type"]}%04d"}"
    zone_id = "${data.aws_route53_zone.route53_zone_internal.zone_id}"
    type    = "A"
    ttl     = "${var.ttl}"
  }

  private_ips = ["${split(",", module.instance_consul.instance_privete_ips)}"]
}

# ------------------------------------------------------
