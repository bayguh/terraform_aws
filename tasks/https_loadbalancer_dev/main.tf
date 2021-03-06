variable "env" {}

variable "https_lb_settings" { type = "map" }
variable "lb_target_group_settings" { type = "map" }
variable "lb_target_group_attachment_settings" { type = "map" }
variable "iam_server_certificate_settings" { type = "map" }
variable "lb_listener_settings" { type = "map" }
variable "lb_listener_rule_settings" { type = "map" }
variable "condition_values" { type = "list" }


# data取得--------------------------------------------------------------------

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

data "aws_s3_bucket" "lb_log_bucket" {
  bucket = "${var.project_name}-lb-log-bucket"
}

data "aws_security_group" "lb_https" {
  filter {
    name   = "tag:Name"
    values = ["${var.env == "prd" ? "${var.project_name}-security-group-lb-https" : "${var.project_name}-${var.env}-security-group-lb-https"}"]
  }
}

data "aws_instances" "web" {
  instance_tags {
    Type = "web"
  }
}

# ---------------------------------------------------------------------------

/**
 * モジュール読み込み
 * httpss://www.terraform.io/docs/configuration/modules.html
 */

# https LB設定--------------------------------------------------------------

# lb
# access log設定 (https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-log-entry-format)
module "https_lb" {
  source = "../../modules/lb_application"

  aws_lb_variables {
    name                       = "${var.env == "prd" ? "${var.project_name}-lb-https" : "${var.project_name}-${var.env}-lb-https"}"
    internal                   = "${var.https_lb_settings["internal"]}"
    enable_deletion_protection = "${var.https_lb_settings["enable_deletion_protection"]}"
    idle_timeout               = "${var.https_lb_settings["idle_timeout"]}"
    access_logs_bucket         = "${data.aws_s3_bucket.lb_log_bucket.id}"
    access_logs_bucket_prefix  = "${var.env}/https"
    access_logs_enabled        = "${var.https_lb_settings["access_logs_enabled"]}"
  }

  security_groups = ["${data.aws_security_group.lb_https.id}"]
  subnets         = "${data.aws_subnet_ids.public.ids}"
}

# lb target group
module "lb_target_group" {
  source = "../../modules/lb_application_target_group"

  aws_lb_target_group_variables {
    name                       = "${var.env == "prd" ? "${var.project_name}-lb-target-group" : "${var.project_name}-${var.env}-lb-target-group"}"
    port                       = "${var.lb_target_group_settings["port"]}"
    protocol                   = "${var.lb_target_group_settings["protocol"]}"
    vpc_id                     = "${data.aws_vpc.vpc.id}"
    deregistration_delay       = "${var.lb_target_group_settings["deregistration_delay"]}"
    stickiness_type            = "${var.lb_target_group_settings["stickiness_type"]}"
    stickiness_cookie_duration = "${var.lb_target_group_settings["stickiness_cookie_duration"]}"
    stickiness_enabled         = "${var.lb_target_group_settings["stickiness_enabled"]}"
    interval                   = "${var.lb_target_group_settings["interval"]}"
    path                       = "${var.lb_target_group_settings["path"]}"
    hc_port                    = "${var.lb_target_group_settings["hc_port"]}"
    hc_protocol                = "${var.lb_target_group_settings["hc_protocol"]}"
    timeout                    = "${var.lb_target_group_settings["timeout"]}"
    healthy_threshold          = "${var.lb_target_group_settings["healthy_threshold"]}"
    unhealthy_threshold        = "${var.lb_target_group_settings["unhealthy_threshold"]}"
    matcher                    = "${var.lb_target_group_settings["matcher"]}"
  }
}

# lb target group attachment
module "lb_target_group_attachment" {
  source = "../../modules/lb_target_group_attachment"

  aws_lb_target_group_attachment_variables {
    count            = "${length(data.aws_instances.web.ids)}"
    target_group_arn = "${module.lb_target_group.lb_target_group_arn}"
    port             = "${var.lb_target_group_attachment_settings["port"]}"
  }

  target_ids = "${data.aws_instances.web.ids}"
}

# iam server certificate
module "iam_server_certificate" {
  source = "../../modules/iam_server_certificate"

  aws_iam_server_certificate_variables {
    name                   = "${var.iam_server_certificate_settings["name"]}"
    certificate_body_path  = "${var.iam_server_certificate_settings["certificate_body_path"]}"
    certificate_chain_path = "${var.iam_server_certificate_settings["certificate_chain_path"]}"
    private_key_path       = "${var.iam_server_certificate_settings["private_key_path"]}"
  }
}

# lb listener
module "lb_listener" {
  source = "../../modules/lb_listener_ssl"

  aws_lb_listener_variables {
    load_balancer_arn = "${module.https_lb.lb_arn}"
    port              = "${var.lb_listener_settings["port"]}"
    protocol          = "${var.lb_listener_settings["protocol"]}"
    target_group_arn  = "${module.lb_target_group.lb_target_group_arn}"
    ssl_policy        = "${var.lb_listener_settings["ssl_policy"]}"
    certificate_arn   = "${module.iam_server_certificate.iam_server_certificate_arn}"
  }
}

# lb listener rule
module "lb_listener_rule" {
  source = "../../modules/lb_listener_rule"

  aws_lb_listener_rule_variables {
    listener_arn     = "${module.lb_listener.lb_listener_arn}"
    priority         = "${var.lb_listener_rule_settings["priority"]}"
    target_group_arn = "${module.lb_target_group.lb_target_group_arn}"
    field            = "${var.lb_listener_rule_settings["field"]}"
  }

  condition_values = "${var.condition_values}"
}
