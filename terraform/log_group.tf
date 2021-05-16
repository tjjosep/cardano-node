resource "aws_cloudwatch_log_group" "this_log_group" {
  name              = "ec2/${var.prefix}-cardano-node"
  retention_in_days = 1
  tags = {
    name = "${var.prefix}-cardano-node"
  }
}