locals {
  private_key_filename = "${var.prefix}-ssh-key.pem"
}

resource "aws_vpc" "this_cardano_node_vpc" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = {
    name = "${var.prefix}-vpc"
  }
}

resource "aws_subnet" "this_cardano_node_subnet" {
  vpc_id     = aws_vpc.this_cardano_node_vpc.id
  cidr_block = var.subnet_prefix

  tags = {
    name = "${var.prefix}-subnet"
  }
}

resource "aws_security_group" "this_cardano_node_sg" {
  name = "${var.prefix}-security-group"

  vpc_id = aws_vpc.this_cardano_node_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.prefix}-security-group"
  }
}

resource "random_id" "app-server-id" {
  prefix      = "${var.prefix}-cardano-node-"
  byte_length = 8
}

resource "aws_internet_gateway" "this_cardano_node_ig" {
  vpc_id = aws_vpc.this_cardano_node_vpc.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

resource "aws_route_table" "this_cardano_node_rt" {
  vpc_id = aws_vpc.this_cardano_node_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this_cardano_node_ig.id
  }
}

resource "aws_route_table_association" "this_cardano_node_rt_assoc" {
  subnet_id      = aws_subnet.this_cardano_node_subnet.id
  route_table_id = aws_route_table.this_cardano_node_rt.id
}

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

resource "tls_private_key" "this_cardano_node_pvt_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "this_cardano_node_key_pair" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.this_cardano_node_pvt_key.public_key_openssh
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

  tags = {
    Name = "${var.prefix}-cardano-node-instance"
  }
}

resource "aws_eip" "this_cardano_node_eip" {
  instance = aws_instance.this_cardano_node_instance.id
  vpc      = true
}

resource "aws_eip_association" "this_cardano_node_eip_assoc" {
  instance_id   = aws_instance.this_cardano_node_instance.id
  allocation_id = aws_eip.this_cardano_node_eip.id
}

# We're using a little trick here so we can run the provisioner without
# destroying the VM. Do not do this in production.

# If you need ongoing management (Day N) of your virtual machines a tool such
# as Chef or Puppet is a better choice. These tools track the state of
# individual files and can keep them in the correct configuration.

# Here we do the following steps:
# Sync everything in files/ to the remote VM.
# Set up some environment variables for our script.
# Add execute permissions to our scripts.
# Run the deploy_app.sh script.
# resource "null_resource" "configure-cat-app" {
#   depends_on = [aws_eip_association.this_cardano_node_eip_assoc]

#   triggers = {
#     build_number = timestamp()
#   }

#   provisioner "file" {
#     source      = "files/"
#     destination = "/home/ubuntu/"

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = tls_private_key.this_cardano_node_pvt_key.private_key_pem
#       host        = aws_eip.this_cardano_node_eip.public_ip
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo add-apt-repository universe",
#       "sudo apt -y update",
#       "sudo apt -y install apache2",
#       "sudo systemctl start apache2",
#       "sudo chown -R ubuntu:ubuntu /var/www/html",
#       "chmod +x *.sh",
#       "PLACEHOLDER=${var.placeholder} WIDTH=${var.width} HEIGHT=${var.height} PREFIX=${var.prefix} ./deploy_app.sh",
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = tls_private_key.this_cardano_node_pvt_key.private_key_pem
#       host        = aws_eip.this_cardano_node_eip.public_ip
#     }
#   }
# }

