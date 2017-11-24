variable "aws_instance_variables" {
    type = "map"
    description = "インスタンス変数"

    default = {
      count         = 0
      name          = ""
      ami           = ""
      instance_type = ""
      key_name      = ""
      volume_type   = ""
      volume_size   = ""
    }
}

variable "vpc_security_group_ids" {
  type = "list"
  default = []
}

variable "subnet_ids" {
  type = "list"
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

  tags {
    Name = "${format(var.aws_instance_variables["name"], count.index+1)}"
  }

  lifecycle {
    ignore_changes = ["ami"]
  }
}

output "instance_ids" {
    value = "${join(",", aws_instance.instance.*.id)}"
}
