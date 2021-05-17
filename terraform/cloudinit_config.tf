data "cloudinit_config" "this_script" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = (templatefile("./scripts/user_data.tpl", {
      loggroup      = aws_cloudwatch_log_group.this_log_group.id
      componentname = "${var.prefix}-cardano-node"
      region        = var.region
    }))
  }
  part {
    content_type = "text/x-shellscript"
    content = templatefile("./scripts/cloud_watch.tpl", {
      loggroup      = aws_cloudwatch_log_group.this_log_group.id
      componentname = "${var.prefix}-cardano-node"
      region        = var.region
    })
  }
}