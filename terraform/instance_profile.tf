locals {
  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

resource "aws_iam_instance_profile" "this_ec2_instance_profile" {
  name = "${var.prefix}-cardano-node-instance-profile"
  role = aws_iam_role.this_ec2_role.name
}

resource "aws_iam_role" "this_ec2_role" {
  name               = "${var.prefix}-cardano-node-role"
  assume_role_policy = data.aws_iam_policy_document.this_ec2_assume_role_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "this_service_policy_attach" {
  count      = length(local.role_policy_arns)
  role       = aws_iam_role.this_ec2_role.name
  policy_arn = element(local.role_policy_arns, count.index)
}

resource "aws_iam_role_policy" "this_inline_cloudwatch_policy" {
  name   = "${var.prefix}-cardano-node-cloudwatch-policy-attach"
  role   = aws_iam_role.this_ec2_role.id
  policy = data.aws_iam_policy_document.this_cloudwatch_doc.json
}

data "aws_iam_policy_document" "this_ec2_assume_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "this_cloudwatch_doc" {
  statement {
    sid = "1"
    actions = [
      "ssm:GetParameter",
    ]
    resources = ["*"]
  }
  statement {
    sid = "2"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = ["arn:aws:logs:::*"]
  }
}








