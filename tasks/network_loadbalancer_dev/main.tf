variable "env" {}

variable "network_lb_settings" { type = "map" }
variable "lb_target_group_settings" { type = "map" }
variable "lb_listener_settings" { type = "map" }

# data取得--------------------------------------------------------------------

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.env == "prd" ? "${var.project_name}-vpc" : "${var.project_name}-${var.env}-vpc"}"]
  }
}

data "aws_subnet_ids" "private-common" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags {
    Type = "private-common"
  }
}

# ---------------------------------------------------------------------------

/**
 * モジュール読み込み
 * https://www.terraform.io/docs/configuration/modules.html
 */

# network LB設定--------------------------------------------------------------

# lb
module "network_lb" {
  source = "../../modules/lb_network"

  aws_lb_variables {
    name                       = "${var.env == "prd" ? "${var.project_name}-lb-network" : "${var.project_name}-${var.env}-lb-network"}"
    internal                   = "${var.network_lb_settings["internal"]}"
    enable_deletion_protection = "${var.network_lb_settings["enable_deletion_protection"]}"
    idle_timeout               = "${var.network_lb_settings["idle_timeout"]}"
    subnet_id                  = "${element(data.aws_subnet_ids.private-common.ids, 0)}"
    allocation_id              = ""
  }
}

# lb target group
module "lb_target_group" {
  source = "../../modules/lb_network_target_group"

  aws_lb_target_group_variables {
    name                 = "${var.env == "prd" ? "${var.project_name}-lb-target-group" : "${var.project_name}-${var.env}-lb-target-group"}"
    port                 = "${var.lb_target_group_settings["port"]}"
    protocol             = "${var.lb_target_group_settings["protocol"]}"
    vpc_id               = "${data.aws_vpc.vpc.id}"
    deregistration_delay = "${var.lb_target_group_settings["deregistration_delay"]}"
    interval             = "${var.lb_target_group_settings["interval"]}"
    path                 = "${var.lb_target_group_settings["path"]}"
    hc_port              = "${var.lb_target_group_settings["hc_port"]}"
    hc_protocol          = "${var.lb_target_group_settings["hc_protocol"]}"
    timeout              = "${var.lb_target_group_settings["timeout"]}"
    healthy_threshold    = "${var.lb_target_group_settings["healthy_threshold"]}"
    unhealthy_threshold  = "${var.lb_target_group_settings["unhealthy_threshold"]}"
    matcher              = "${var.lb_target_group_settings["matcher"]}"
  }
}

# lb listener
module "lb_listener" {
  source = "../../modules/lb_listener"

  aws_lb_listener_variables {
    load_balancer_arn = "${module.network_lb.lb_arn}"
    port              = "${var.lb_listener_settings["port"]}"
    protocol          = "${var.lb_listener_settings["protocol"]}"
    target_group_arn  = "${module.lb_target_group.lb_target_group_arn}"
  }
}
