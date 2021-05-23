locals {
  private_key_filename = "${var.prefix}-ssh-key.pem"
}

resource "tls_private_key" "this_cardano_node_pvt_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "this_cardano_node_key_pair" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.this_cardano_node_pvt_key.public_key_openssh
}