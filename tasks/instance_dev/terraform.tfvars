// 環境
env = "dev"

instance_ansible_settings {
  count         = 1
  ami           = "ami-2803ac4e"
  instance_type = "t2.micro"
  key_name      = "access-key"
  volume_type   = "gp2"
  volume_size   = 20
}

instance_web_settings {
  count         = 2
  ami           = "ami-2803ac4e"
  instance_type = "t2.micro"
  key_name      = "access-key"
  volume_type   = "gp2"
  volume_size   = 20
}

instance_db_settings {
  count                    = 1
  ami                      = "ami-2803ac4e"
  instance_type            = "t2.micro"
  key_name                 = "access-key"
  volume_type              = "gp2"
  volume_size              = 20
  ebs_device_name          = "/dev/sdb"
  ebs_volume_type          = "gp2"
  ebs_volume_size          = 100
  private_key              = "../../keys/ssh/access-key.pem"
  disk_partition_file_path = "../../scripts/disk_partition/disk_partition.sh"
  mount_path               = "/var/lib/mysql5.7"
}

instance_bastion_settings {
  count         = 1
  ami           = "ami-2803ac4e"
  instance_type = "t2.micro"
  key_name      = "access-key"
  volume_type   = "gp2"
  volume_size   = 20
}

instance_consul_settings {
  count         = 1
  ami           = "ami-2803ac4e"
  instance_type = "t2.micro"
  key_name      = "access-key"
  volume_type   = "gp2"
  volume_size   = 20
}
