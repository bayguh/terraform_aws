// 環境
env = "dev"

# VPC
vpc_settings {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# zones
subnet_availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]

# Subnet public
subnet_public_cidr_blocks = ["10.1.0.0/20", "10.1.16.0/20"]

# Route Table public
route_table_public_settings {
  cidr_block = "0.0.0.0/0"
}

# Subnet private common
subnet_private_common_cidr_blocks = ["10.1.32.0/20"]
# Subnet private web
subnet_private_web_cidr_blocks = ["10.1.48.0/20"]
# Subnet private db
subnet_private_db_cidr_blocks = ["10.1.64.0/20"]
# Subnet private cache
subnet_private_cache_cidr_blocks = ["10.1.80.0/20"]

# Route Table private
route_table_private_settings {
  cidr_block = "0.0.0.0/0"
}

# endpoint s3
endpoint_s3_settings {
  service_name = "com.amazonaws.ap-northeast-1.s3"
}
