# resource "aws_ebs_volume" "this_ebs_volume" {
#   availability_zone = aws_subnet.this_cardano_node_subnet.availability_zone
#   size              = 40

#   tags = {
#     Name = "${var.prefix}-cardano-node-volume"
#   }
# }