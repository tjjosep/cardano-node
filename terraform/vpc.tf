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


