// 環境
env="prd"

# VPC
vpc_settings {
  name                 = "bayguh_vpc"
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Subnet
subnet_prd_settings {
  name              = "bayguh-prd-subnet"
  cidr_block        = "10.0.0.0/16"
  availability_zone = "ap-northeast-1a"
}

# Internet Gateway
internet_gateway_settings {
  name = "bayguh-internet-gateway"
}

# Route Table
route_table_settings {
  name       = "public-access-route-table"
  cidr_block = "0.0.0.0/0"
}
