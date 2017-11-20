variable "env" {}

variable "vpc_settings" { type = "map" }
variable "subnet_prd_settings" { type = "map" }
variable "internet_gateway_settings" { type = "map" }
variable "route_table_settings" { type = "map" }

/**
 * モジュール読み込み
 * https://www.terraform.io/docs/configuration/modules.html
 */

# VPC設定-------------------------------------------

# VPC
module "vpc" {
  source = "../../modules/vpc"

  aws_vpc_variables {
    name                 = "${var.vpc_settings["name"]}"
    cidr_block           = "${var.vpc_settings["cidr_block"]}"
    instance_tenancy     = "${var.vpc_settings["instance_tenancy"]}"
    enable_dns_support   = "${var.vpc_settings["enable_dns_support"]}"
    enable_dns_hostnames = "${var.vpc_settings["enable_dns_hostnames"]}"
  }
}

# Subnet
module "subnet_prd" {
  source = "../../modules/subnet"

  aws_subnet_variables {
    name              = "${var.subnet_prd_settings["name"]}"
    vpc_id            = "${module.vpc.vpc_id}"
    cidr_block        = "${var.subnet_prd_settings["cidr_block"]}"
    availability_zone = "${var.subnet_prd_settings["availability_zone"]}"
  }
}

# Internet Gateway
module "internet_gateway" {
  source = "../../modules/internet_gateway"

  aws_internet_gateway_variables {
    name   = "${var.internet_gateway_settings["name"]}"
    vpc_id = "${module.vpc.vpc_id}"
  }
}

# Route Table
module "route_table" {
  source = "../../modules/route_table"

  aws_route_table_variables {
    name       = "${var.route_table_settings["name"]}"
    vpc_id     = "${module.vpc.vpc_id}"
    cidr_block = "${var.route_table_settings["cidr_block"]}"
    gateway_id = "${module.internet_gateway.internet_gateway_id}"
  }
}

# Route Table Association
module "route_table_association" {
  source = "../../modules/route_table_association"

  aws_route_table_association_variables {
    subnet_id      = "${module.subnet_prd.subnet_id}"
    route_table_id = "${module.route_table.route_table_id}"
  }
}
