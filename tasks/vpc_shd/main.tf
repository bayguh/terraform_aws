variable "env" {}

variable "vpc_settings" { type = "map" }
variable "subnet_availability_zones" { type = "list" }

variable "subnet_public_cidr_blocks" { type = "list" }
variable "route_table_public_settings" { type = "map" }

variable "subnet_private_cidr_blocks" { type = "list" }
variable "route_table_private_settings" { type = "map" }

variable "endpoint_s3_settings" { type = "map" }

/**
 * モジュール読み込み
 * https://www.terraform.io/docs/configuration/modules.html
 */

# VPC設定--------------------------------------------------------------

# VPC
module "vpc" {
  source = "../../modules/vpc"

  aws_vpc_variables {
    name                 = "${var.env == "prd" ? "${var.project_name}-vpc" : "${var.project_name}-${var.env}-vpc"}"
    cidr_block           = "${var.vpc_settings["cidr_block"]}"
    instance_tenancy     = "${var.vpc_settings["instance_tenancy"]}"
    enable_dns_support   = "${var.vpc_settings["enable_dns_support"]}"
    enable_dns_hostnames = "${var.vpc_settings["enable_dns_hostnames"]}"
  }
}

# public --------------------------------

# Subnet public
module "subnet_public" {
  source = "../../modules/subnet"

  aws_subnet_variables {
    name   = "${var.env == "prd" ? "${var.project_name}-subnet-public%02d" : "${var.project_name}-${var.env}-subnet-public%02d"}"
    vpc_id = "${module.vpc.vpc_id}"
    type   = "public"
  }

  cidr_blocks        = "${var.subnet_public_cidr_blocks}"
  availability_zones = "${var.subnet_availability_zones}"
}

# Internet Gateway
module "internet_gateway" {
  source = "../../modules/internet_gateway"

  aws_internet_gateway_variables {
    name   = "${var.env == "prd" ? "${var.project_name}-internet-gateway" : "${var.project_name}-${var.env}-internet-gateway"}"
    vpc_id = "${module.vpc.vpc_id}"
  }
}

# Route Table public
module "route_table_public" {
  source = "../../modules/route_table"

  aws_route_table_variables {
    name       = "${var.env == "prd" ? "${var.project_name}-route-table-public" : "${var.project_name}-${var.env}-route-table-public"}"
    vpc_id     = "${module.vpc.vpc_id}"
    cidr_block = "${var.route_table_public_settings["cidr_block"]}"
    gateway_id = "${module.internet_gateway.internet_gateway_id}"
  }
}

# Route Table Association public
module "route_table_association_public" {
  source = "../../modules/route_table_association"

  aws_route_table_association_variables {
    count          = "${length(var.subnet_public_cidr_blocks)}"
    route_table_id = "${module.route_table_public.route_table_id}"
  }

  subnet_ids = ["${split(",", module.subnet_public.subnet_ids)}"]
}

# ----------------------------------------

# private --------------------------------

# Subnet private
module "subnet_private" {
  source = "../../modules/subnet"

  aws_subnet_variables {
    name   = "${var.env == "prd" ? "${var.project_name}-subnet-private%02d" : "${var.project_name}-${var.env}-subnet-private%02d"}"
    vpc_id = "${module.vpc.vpc_id}"
    type   = "private"
  }

  cidr_blocks        = "${var.subnet_private_cidr_blocks}"
  availability_zones = "${var.subnet_availability_zones}"
}

# nat gateway用eip
module "eip_nat_gateway" {
  source = "../../modules/eip"

  aws_eip_variables {
    vpc = true
  }
}

# NAT Gateway
module "nat_gateway" {
  source = "../../modules/nat_gateway"

  aws_nat_gateway_variables {
    name          = "${var.env == "prd" ? "${var.project_name}-nat-gateway" : "${var.project_name}-${var.env}-nat-gateway"}"
    allocation_id = "${module.eip_nat_gateway.eip_id}"
    subnet_id     = "${element(split(",", module.subnet_public.subnet_ids), 0)}"
  }
}

# Route Table private
module "route_table_private" {
  source = "../../modules/route_table_nat_gateway"

  aws_route_table_variables {
    name           = "${var.env == "prd" ? "${var.project_name}-route-table-private" : "${var.project_name}-${var.env}-route-table-private"}"
    vpc_id         = "${module.vpc.vpc_id}"
    cidr_block     = "${var.route_table_private_settings["cidr_block"]}"
    nat_gateway_id = "${module.nat_gateway.nat_gateway_id}"
  }
}

# Route Table Association private
module "route_table_association_private" {
  source = "../../modules/route_table_association"

  aws_route_table_association_variables {
    count          = "${length(var.subnet_private_cidr_blocks)}"
    route_table_id = "${module.route_table_private.route_table_id}"
  }

  subnet_ids = ["${module.subnet_private.subnet_ids}"]
}

# ----------------------------------------

# endpoint ----------------------------------------

# endpoint s3
module "endpoint_s3" {
  source = "../../modules/endpoint"

  aws_vpc_endpoint_variables {
    service_name = "${var.endpoint_s3_settings["service_name"]}"
    vpc_id       = "${module.vpc.vpc_id}"
  }

  route_table_ids = ["${module.route_table_public.route_table_id}", "${module.route_table_private.route_table_id}"]
}

# --------------------------------------------------

# DHCP ---------------------------------------------

# route53 zone
module "route53_zone_vpc" {
  source = "../../modules/route53_zone_vpc"

  aws_route53_zone_variables {
    name   = "${var.env == "prd" ? "${var.project_name}.internal." : "${var.project_name}-${var.env}.internal."}"
    vpc_id = "${module.vpc.vpc_id}"
  }
}

# dhcp options
module "dhcp_options" {
  source = "../../modules/dhcp_options"

  aws_vpc_dhcp_options_variables {
    name        = "${var.env == "prd" ? "${var.project_name}-dhcp" : "${var.project_name}-${var.env}-dhcp"}"
    domain_name = "${module.route53_zone_vpc.zone_name} ap-northeast-1.compute.internal"
  }

  domain_name_servers = ["AmazonProvidedDNS"]
}

# dhcp options association
module "dhcp_options_association" {
  source = "../../modules/dhcp_options_association"

  aws_vpc_dhcp_options_association_variables {
    vpc_id          = "${module.vpc.vpc_id}"
    dhcp_options_id = "${module.dhcp_options.dhcp_options_ip}"
  }
}

# --------------------------------------------------
