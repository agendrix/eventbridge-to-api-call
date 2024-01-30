locals {
  lambda_zip = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.name
  filename         = local.lambda_zip
  source_code_hash = filebase64sha256(local.lambda_zip)
  handler          = "index.handler"
  role             = aws_iam_role.lambda_execution_role.arn

  runtime = "nodejs18.x"

  environment {
    variables = {
      API_URL = var.api_config.api_url
      API_KEY = var.api_config.api_key
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.sns_topic_to_notify_on_failure != null ? [var.sns_topic_to_notify_on_failure] : []
    iterator = sns_topic_arn
    content {
      target_arn = sns_topic_arn.value
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "allow_list_account_aliases" {
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "iam:ListAccountAliases"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "allow_sns_topic_notification" {
  count = var.sns_topic_to_notify_on_failure != null ? 1 : 0
  role  = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sns:Publish"
        Resource = var.sns_topic_to_notify_on_failure
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_invocation_from_eventbridge" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.custom_event.arn
}

resource "aws_cloudwatch_event_rule" "custom_event" {
  name          = aws_lambda_function.lambda.function_name
  event_pattern = var.event_pattern
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  target_id = aws_cloudwatch_event_rule.custom_event.name
  rule      = aws_cloudwatch_event_rule.custom_event.name
  arn       = aws_lambda_function.lambda.arn

  input_transformer {
    input_paths    = var.input_transformer.input_paths
    input_template = var.input_transformer.input_template

  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 14
}
