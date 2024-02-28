# Eventbridge to API call

_An AWS Lambda for sending EventBridge events to API endpoint

![Release](https://github.com/agendrix/eventbridge-slack-notifier/workflows/Release/badge.svg) ![Tests](https://github.com/agendrix/eventbridge-slack-notifier/workflows/Tests/badge.svg?branch=main)

## Description

The goal of this module is to send a POST to a specific API endpoint when an EventBridge [rule](https://docs.aws.amazon.com/eventbridge/latest/userguide/create-eventbridge-rule.html) is triggered.

## Lambda payload

The lambda function payload is an object with the following type:
```ts
type Payload = {
  headers: {
    "Authorization": string,
    [key: string]: string
  };
  data: JSON;
};
```
`headers`: Need at least the key `Authorization` to access the API

`data`: All the data you want to send to the API. Can be empty

## How to use with Terraform
Add the module to your [Terraform](https://www.terraform.io/) project:

```HCL
module "eventbridge_logger_opgenie" {
  source                         = "github.com/agendrix/eventbridge-to-make-api-call.git//terraform?ref=v0.1.2"
  sns_topic_to_notify_on_failure = <aws_sns_topic_arn>
  name                           = "Ressource Name"

  api_config = {
    api_url = "<MY_API_URL>"
    api_key = "<MY_API_KEY_SECRET>"
  }

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
  })

  input_transformer = {
    input_paths = {
      source                     = "$.source"
      time                       = "$.time"
      alarm                      = "$.detail.alarmName"
    }

    input_template = <<EOF
    {
      "headers": {
        "Content-Type": "application/json",
        "Authorization": "Key "
      },
      "data": {
        "message": "My Message <source>",
        "description": "My Description: <time> <alarm>",
      }
    } 
    EOF
  }
}
```

### Resources:

[How to create a rule pattern](https://docs.aws.amazon.com/eventbridge/latest/userguide/eventbridge-and-event-patterns.html)

[Input transformer](https://docs.aws.amazon.com/eventbridge/latest/userguide/transform-input.html)

[Input transformer Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target#input_transformer)

[Common input transformer issues](https://docs.aws.amazon.com/eventbridge/latest/userguide/transform-input.html#transform-input-issues)
