variable "aws_instance_variables" {
    type        = "map"
    description = "インスタンス変数"

    default = {
      count                       = 0
      name                        = ""
      ami                         = ""
      instance_type               = ""
      key_name                    = ""
      associate_public_ip_address = ""
      volume_type                 = ""
      volume_size                 = ""
      private_key                 = ""
      update_hostname_file_path   = ""
      type                        = ""
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
  associate_public_ip_address = "${var.aws_instance_variables["associate_public_ip_address"]}"

  root_block_device = {
    volume_type = "${var.aws_instance_variables["volume_type"]}"
    volume_size = "${var.aws_instance_variables["volume_size"]}"
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
    source      = "${var.aws_instance_variables["update_hostname_file_path"]}"
    destination = "/tmp/update_hostname.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sh /tmp/update_hostname.sh ${format(var.aws_instance_variables["name"], count.index+1)}",
      "rm /tmp/update_hostname.sh"
    ]
  }
}

output "instance_ids" {
    value = "${join(",", aws_instance.instance.*.id)}"
}

output "instance_privete_ips" {
    value = "${join(",", aws_instance.instance.*.private_ip)}"
}
