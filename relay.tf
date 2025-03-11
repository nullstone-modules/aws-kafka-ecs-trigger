locals {
  relay_name = "${data.ns_workspace.this.block_ref}-relay-${random_string.resource_suffix.result}"
}

data "archive_file" "relay" {
  type        = "zip"
  source_file = "${path.module}/relay.js"
  output_path = "${path.module}/relay.zip"
}

resource "aws_lambda_function" "relay" {
  function_name = local.relay_name
  handler       = "index.handler"
  role          = aws_iam_role.relay.arn
  runtime       = "nodejs16.x"
  tags          = local.tags

  filename         = data.archive_file.relay.output_path
  source_code_hash = data.archive_file.relay.output_base64sha256

  environment {
    variables = {
      ECS_CLUSTER_ARN     = local.app_cluster_arn
      ECS_TASK_DEFINITION = local.app_task_definition_name
      SUBNETS             = local.app_subnet_ids
      SECURITY_GROUPS     = local.app_security_group_id
      ECS_LAUNCH_TYPE     = local.app_launch_type
      MAIN_CONTAINER      = local.app_main_container
    }
  }
}

resource "aws_iam_role" "relay" {
  name               = local.relay_name
  assume_role_policy = data.aws_iam_policy_document.relay_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "relay_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "relay_basic" {
  role       = aws_iam_role.relay.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "relay_msk" {
  role       = aws_iam_role.relay.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaMSKExecutionRole"
}

resource "aws_iam_role_policy" "relay" {
  role   = aws_iam_role.relay.name
  policy = data.aws_iam_policy_document.relay.json
}

data "aws_iam_policy_document" "relay" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${local.account_id}:role/${local.app_role_name}"]
  }
}
