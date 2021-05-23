
data "aws_ami" "this_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "this_cardano_node_instance" {
  ami                         = data.aws_ami.this_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this_cardano_node_key_pair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.this_cardano_node_subnet.id
  vpc_security_group_ids      = [aws_security_group.this_cardano_node_sg.id]
  user_data                   = data.cloudinit_config.this_script.rendered
  monitoring                  = true
  iam_instance_profile        = aws_iam_instance_profile.this_ec2_instance_profile.name

  root_block_device {
    delete_on_termination = true
    volume_size           = 40
    volume_type           = "gp2"

  }

  tags = {
    Name = "${var.prefix}-cardano-node-instance"
  }
}
