# EB Direct Targets

Rule on a classic event bus delivering straight to an AWS service resource in another account in the same region, with no intermediate bus, Lambda, or SNS bridge. Use this when the receiving team should only grant access to its queue, topic, function, stream, or API.

## Timeline

| Date | Item | AWS News | AWS Blog | AWS Docs | Notes |
| --- | --- | --- | --- | --- | --- |
| 2025-01-21 | Direct delivery to cross-account targets | [News](https://aws.amazon.com/about-aws/whats-new/2025/01/amazon-eventbridge-direct-delivery-cross-account-targets/) | [Blog](https://aws.amazon.com/blogs/compute/introducing-cross-account-targets-for-amazon-eventbridge-event-buses/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-service-cross-account.html) | SQS, SNS, Lambda, Kinesis Data Streams, and API Gateway targets in another account, all commercial regions. |
| 2025-04-25 | Direct delivery in AWS GovCloud (US) | [News](https://aws.amazon.com/about-aws/whats-new/2025/04/amazon-eventbridge-cross-account-event-delivery-govcloud/) | Not found | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-service-cross-account.html) | Same model expanded to AWS GovCloud (US-East and US-West). |

## Direct Target Indicators

| Indicator | Meaning |
| --- | --- |
| Rule target ARN in another account that is not an `event-bus` | Direct cross-account target. |
| Target `RoleArn` in the bus account | Required execution role; the bus account's SCPs apply. |
| Resource policy on the target | Target account side of the trust. Only targets with resource-based policies are supported. |
| `aws:ResourceOrgID` deny SCP | Stops rules invoking resources outside the organization. |
| Target in another region | Not supported; use EB Bus-to-Bus. |
| `PutTargets` from the target account | Not supported for non-bus cross-account targets; the bus account owns the rule and target. |
