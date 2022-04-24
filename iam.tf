resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ssm_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ssm_permissions" {
  name   = "ssm"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = data.aws_iam_policy_document.ssm_permissions.json
}

data "aws_iam_policy_document" "logging_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "logging_permissions" {
  name   = "logging"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = data.aws_iam_policy_document.logging_permissions.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "assume_role" {
  name   = "assume_role"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = data.aws_iam_policy_document.assume_role.json
}
