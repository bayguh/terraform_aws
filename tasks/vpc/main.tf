variable "env" {}

variable "vpc_settings" { type = "map" }
variable "subnet_availability_zones" { type = "list" }
variable "subnet_web_cidr_blocks" { type = "list" }
variable "subnet_db_cidr_blocks" { type = "list" }

variable "route_table_settings" { type = "map" }

/**
 * モジュール読み込み
 * https://www.terraform.io/docs/configuration/modules.html
 */

# VPC設定-------------------------------------------

# VPC prd
module "vpc_prd" {
  source = "../../modules/vpc"

  aws_vpc_variables {
    name                 = "${var.project_name}-vpc"
    cidr_block           = "${var.vpc_settings["cidr_block"]}"
    instance_tenancy     = "${var.vpc_settings["instance_tenancy"]}"
    enable_dns_support   = "${var.vpc_settings["enable_dns_support"]}"
    enable_dns_hostnames = "${var.vpc_settings["enable_dns_hostnames"]}"
  }
}

# Subnet web
module "subnet_web" {
  source = "../../modules/subnet"

  aws_subnet_variables {
    name   = "${var.project_name}-subnet-web%02d"
    vpc_id = "${module.vpc_prd.vpc_id}"
  }

  cidr_blocks        = "${var.subnet_web_cidr_blocks}"
  availability_zones = "${var.subnet_availability_zones}"
}

# Subnet db
module "subnet_db" {
  source = "../../modules/subnet"

  aws_subnet_variables {
    name              = "${var.project_name}-subnet-db%02d"
    vpc_id            = "${module.vpc_prd.vpc_id}"
  }

  cidr_blocks        = "${var.subnet_db_cidr_blocks}"
  availability_zones = "${var.subnet_availability_zones}"
}

# Internet Gateway
module "internet_gateway" {
  source = "../../modules/internet_gateway"

  aws_internet_gateway_variables {
    name   = "${var.project_name}-internet-gateway"
    vpc_id = "${module.vpc_prd.vpc_id}"
  }
}

# Route Table
module "route_table" {
  source = "../../modules/route_table"

  aws_route_table_variables {
    name       = "${var.project_name}-internet-route-table"
    vpc_id     = "${module.vpc_prd.vpc_id}"
    cidr_block = "${var.route_table_settings["cidr_block"]}"
    gateway_id = "${module.internet_gateway.internet_gateway_id}"
  }
}

# Route Table Association
module "route_table_association" {
  source = "../../modules/route_table_association"

  aws_route_table_association_variables {
    count = "${length(var.subnet_web_cidr_blocks)}"
    route_table_id = "${module.route_table.route_table_id}"
  }

  subnet_ids = ["${(split(",", module.subnet_web.subnet_ids))}"]
}
