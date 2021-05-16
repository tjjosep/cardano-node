# Outputs file
output "catapp_url" {
  value = "http://${aws_eip.this_cardano_node_eip.public_dns}"
}
