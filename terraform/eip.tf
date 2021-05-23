resource "aws_eip" "this_cardano_node_eip" {
  instance = aws_instance.this_cardano_node_instance.id
  vpc      = true
}

resource "aws_eip_association" "this_cardano_node_eip_assoc" {
  instance_id   = aws_instance.this_cardano_node_instance.id
  allocation_id = aws_eip.this_cardano_node_eip.id
}
