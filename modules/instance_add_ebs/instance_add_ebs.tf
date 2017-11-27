variable "aws_instance_variables" {
    type        = "map"
    description = "インスタンス変数"

    default = {
      count                    = 0
      name                     = ""
      ami                      = ""
      instance_type            = ""
      key_name                 = ""
      volume_type              = ""
      volume_size              = ""
      ebs_device_name          = ""
      ebs_volume_type          = ""
      ebs_volume_size          = ""
      private_key              = ""
      disk_partition_file_path = ""
      mount_path               = ""
      type                     = ""
    }
}

variable "vpc_security_group_ids" {
  type    = "list"
  default = []
}

variable "subnet_ids" {
  type    = "list"
  default = []
}

/**
 * インスタンス作成
 * https://www.terraform.io/docs/providers/aws/r/instance.html
 */
resource "aws_instance" "instance" {
  count                       = "${var.aws_instance_variables["count"]}"
  ami                         = "${var.aws_instance_variables["ami"]}"
  instance_type               = "${var.aws_instance_variables["instance_type"]}"
  key_name                    = "${var.aws_instance_variables["key_name"]}"
  vpc_security_group_ids      = ["${var.vpc_security_group_ids}"]
  subnet_id                   = "${element(var.subnet_ids, count.index%length(var.subnet_ids))}"
  associate_public_ip_address = "false"

  root_block_device = {
    volume_type = "${var.aws_instance_variables["volume_type"]}"
    volume_size = "${var.aws_instance_variables["volume_size"]}"
  }

  ebs_block_device = {
    device_name = "${var.aws_instance_variables["ebs_device_name"]}"
    volume_type = "${var.aws_instance_variables["ebs_volume_type"]}"
    volume_size = "${var.aws_instance_variables["ebs_volume_size"]}"
  }

  tags {
    Name = "${format(var.aws_instance_variables["name"], count.index+1)}"
    Type = "${var.aws_instance_variables["type"]}"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${file(var.aws_instance_variables["private_key"])}"
  }

  provisioner "file" {
    source      = "${var.aws_instance_variables["disk_partition_file_path"]}"
    destination = "/tmp/disk_partition.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh /tmp/disk_partition.sh ${var.aws_instance_variables["mount_path"]}",
      "rm /tmp/disk_partition.sh"
    ]
  }
}

output "instance_ids" {
    value = "${join(",", aws_instance.instance.*.id)}"
}
