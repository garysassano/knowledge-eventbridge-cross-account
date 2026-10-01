# EB Direct Targets

A rule on a classic event bus delivers events straight to an AWS service resource in another account, with no intermediate bus, Lambda, or SNS bridge. Trust is mutual: an execution role in the bus account plus a resource policy on the target. Use this when the receiving team should not have to run EventBridge at all.

## Timeline

| Date | Item | AWS News | AWS Blog | AWS Docs | Notes |
| --- | --- | --- | --- | --- | --- |
| 2025-01-21 | Direct delivery to cross-account targets | [News](https://aws.amazon.com/about-aws/whats-new/2025/01/amazon-eventbridge-direct-delivery-cross-account-targets/) | [Blog](https://aws.amazon.com/blogs/compute/introducing-cross-account-targets-for-amazon-eventbridge-event-buses/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-service-cross-account.html) | All commercial regions. Supported targets are SQS, SNS, Lambda, Kinesis Data Streams, and API Gateway. |
| 2025-04-25 | Direct delivery in AWS GovCloud (US) | [News](https://aws.amazon.com/about-aws/whats-new/2025/04/amazon-eventbridge-cross-account-event-delivery-govcloud/) | Not found | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-service-cross-account.html) | Same model in GovCloud (US-East and US-West). |

## Setup Order

1. Target account: create the target (for example an SQS queue).
2. Source account: create the rule with the target ARN and an execution role allowed to call the target (for example `sqs:SendMessage`).
3. Target account: attach a resource policy on the target allowing the source account or the execution role.

## Behaviour Indicators

| Indicator | Meaning |
| --- | --- |
| Rule target ARN in another account that is not an `event-bus` | Direct cross-account target. |
| Target `RoleArn` in the bus account | Required. EventBridge assumes it, so the bus account's SCPs apply. |
| Resource policy on the SQS queue / SNS topic / Lambda function / Kinesis stream / API | Target side of the trust. Targets without resource-based policies cannot be used. |
| `aws:ResourceOrgID` deny SCP | Stops rules from invoking resources outside the organization. |
| Target region differs from the bus region | Not supported: rule and target must be in the same region. Use EB Bus-to-Bus for cross-region. |
| `PutTargets` called from the target account | Not supported for non-bus cross-account targets, even with a role from the caller's account. The bus account owns the rule and target. |
