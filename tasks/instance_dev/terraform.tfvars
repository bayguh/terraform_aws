// 環境
env = "dev"

// デフォルトttl
ttl = "300"

instance_ansible_settings {
  count                       = 1
  ami                         = "ami-2803ac4e"
  instance_type               = "t2.micro"
  key_name                    = "access-key"
  associate_public_ip_address = true
  volume_type                 = "gp2"
  volume_size                 = 20
  private_key                 = "../../keys/ssh/access-key.pem"
  update_hostname_file_path   = "../../scripts/update_hostname/update_hostname.sh"
  type                        = "ansible"
}

instance_web_settings {
  count                       = 2
  ami                         = "ami-2803ac4e"
  instance_type               = "t2.micro"
  key_name                    = "access-key"
  associate_public_ip_address = false
  volume_type                 = "gp2"
  volume_size                 = 20
  private_key                 = "../../keys/ssh/access-key.pem"
  update_hostname_file_path   = "../../scripts/update_hostname/update_hostname.sh"
  type                        = "web"
}

instance_db_settings {
  count                       = 1
  ami                         = "ami-2803ac4e"
  instance_type               = "t2.micro"
  key_name                    = "access-key"
  associate_public_ip_address = false
  volume_type                 = "gp2"
  volume_size                 = 20
  ebs_device_name             = "/dev/sdb"
  ebs_volume_type             = "gp2"
  ebs_volume_size             = 100
  private_key                 = "../../keys/ssh/access-key.pem"
  update_hostname_file_path   = "../../scripts/update_hostname/update_hostname.sh"
  disk_partition_file_path    = "../../scripts/disk_partition/disk_partition.sh"
  mount_path                  = "/var/lib/mysql5.7"
  type                        = "db"
}

instance_bastion_settings {
  count                       = 1
  ami                         = "ami-2803ac4e"
  instance_type               = "t2.micro"
  key_name                    = "access-key"
  associate_public_ip_address = true
  volume_type                 = "gp2"
  volume_size                 = 20
  private_key                 = "../../keys/ssh/access-key.pem"
  update_hostname_file_path   = "../../scripts/update_hostname/update_hostname.sh"
  type                        = "bastion"
}

instance_consul_settings {
  count                       = 1
  ami                         = "ami-2803ac4e"
  instance_type               = "t2.micro"
  key_name                    = "access-key"
  associate_public_ip_address = false
  volume_type                 = "gp2"
  volume_size                 = 20
  private_key                 = "../../keys/ssh/access-key.pem"
  update_hostname_file_path   = "../../scripts/update_hostname/update_hostname.sh"
  type                        = "consul"
}
