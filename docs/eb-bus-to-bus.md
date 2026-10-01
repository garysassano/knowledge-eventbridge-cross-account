# EB Bus-to-Bus

Rule on a sender event bus targeting an event bus in another account and/or region, authorized by the receiver bus resource policy. Use this for cross-region routing or when the receiver must own its own rules, archive, and onward routing.

## Timeline

| Date | Item | AWS News | AWS Blog | AWS Docs | Notes |
| --- | --- | --- | --- | --- | --- |
| 2017-06-30 | CloudWatch Events cross-account event delivery | [News](https://aws.amazon.com/about-aws/whats-new/2017/06/cloudwatch-events-adds-cross-account-event-delivery-support/) | [Blog](https://aws.amazon.com/blogs/aws/new-cross-account-delivery-of-cloudwatch-events/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cross-account.html) | Default event bus can target an event bus in another account. `PutPermission` / `RemovePermission` manage the receiving bus policy. |
| 2018-10-22 | Share events across all accounts in an organization | Not found | Not found | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-bus-perms.html) | Organization-wide grant using `aws:PrincipalOrgID` instead of listing accounts. AWS News page has been retired. |
| 2020-11-20 | Improved resource policies for event buses | [News](https://aws.amazon.com/about-aws/whats-new/2020/11/amazon-eventbridge-announces-improved-resource-policies-for-event-buses/) | [Blog](https://aws.amazon.com/blogs/compute/simplifying-cross-account-access-with-amazon-eventbridge-resource-policies/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-bus-perms.html) | Bus policy authorizes `PutEvents`, `PutRule`, and `PutTargets` from other accounts, with conditions on source, detail-type, and rule creator. |
| 2021-04-15 | Cross-region event bus targets | [News](https://aws.amazon.com/about-aws/whats-new/2021/04/amazon-eventbridge-introduces-support-cross-region-event-bus-targets/) | [Blog](https://aws.amazon.com/blogs/compute/introducing-cross-region-event-routing-with-amazon-eventbridge/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cross-region.html) | Any commercial region can route to an event bus in us-east-1, us-west-2, or eu-west-1, same or other account. |
| 2021-11-22 | Cross-region destinations expanded | [News](https://aws.amazon.com/about-aws/whats-new/2021/11/amazon-eventbridge-cross-region-expands/) | [Blog](https://aws.amazon.com/blogs/compute/expanding-cross-region-event-routing-with-amazon-eventbridge/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cross-region.html) | All regions except AWS GovCloud (US) and China can be cross-region destinations. |

## IAM Role Requirement

This is an EventBridge User Guide note, not a public AWS News announcement.

| Date | Scope | Source | Reference docs | Notes |
| --- | --- | --- | --- | --- |
| 2023-03-02 | EB Bus-to-Bus | EventBridge User Guide | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cross-account.html) | All new cross-account event bus targets must have an IAM execution role. |

Key points from the note:

- Targets created without a role before 2023-03-02 are not affected.
- AWS still recommends adding a role to old targets.
- With a role, AWS Organizations SCPs on the sender account apply to the delivery.
- The console creates the role automatically; the CLI, SDKs, and IaC do not.

## Bus-to-Bus Indicators

| Indicator | Meaning |
| --- | --- |
| `AWS::Events::EventBusPolicy` / `PutPermission` | Receiver bus resource policy granting accounts, an organization, or everyone. |
| `aws:PrincipalOrgID` | Organization-wide grant on the receiver bus. |
| Rule target `arn:aws:events:<region>:<other-account>:event-bus/<name>` with `RoleArn` | Sender side of bus-to-bus. Role trusts `events.amazonaws.com` and allows `events:PutEvents` on the receiver bus. |
| `account` field in receiver rule patterns | Required to stop receiver rules matching events from every allowed sender. `"*"` never matches. |
| Receiver rule forwarding to a third account | Not delivered; bus-to-bus is one hop only. |
| Billing | Sender pays for the events as custom events; the receiver is not charged for the hop. |
