data "cloudinit_config" "this_script" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = (templatefile("./scripts/userdata.tpl", {
      loggroup      = aws_cloudwatch_log_group.this_log_group.id
      componentname = "${var.prefix}-cardano-node"
    }))
  }
  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/cloudwatch.tpl", {
      loggroup      = aws_cloudwatch_log_group.this_log_group.id
      componentname = "${var.prefix}-cardano-node"
    })
  }
  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/cardanonode.tpl", {
      loggroup      = aws_cloudwatch_log_group.this_log_group.id
      componentname = "${var.prefix}-cardano-node"
    })
  }
}