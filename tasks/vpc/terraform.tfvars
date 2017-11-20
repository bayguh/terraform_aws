// 環境
env="prd"

# VPC
vpc_settings {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Subnet
subnet_availability_zones = ["ap-northeast-1a", "ap-northeast-1b", "ap-northeast-1c"]
# Subnet web
subnet_web_cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
# Subnet db
subnet_db_cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]

# Internet Gateway
internet_gateway_settings {
  name = "bayguh-internet-gateway"
}

# Route Table
route_table_settings {
  name       = "public-access-route-table"
  cidr_block = "0.0.0.0/0"
}
