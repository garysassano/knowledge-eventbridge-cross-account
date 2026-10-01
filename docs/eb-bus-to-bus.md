# EB Bus-to-Bus

A rule on a sender's event bus targets an event bus in another account and/or region. The receiver grants access with a bus resource policy and routes the events on with its own rules. This is the original CloudWatch Events cross-account model and still the only EventBridge option that crosses regions.

## Timeline

| Date | Item | AWS News | AWS Blog | AWS Docs | Notes |
| --- | --- | --- | --- | --- | --- |
| 2017-06-30 | CloudWatch Events cross-account event delivery | [News](https://aws.amazon.com/about-aws/whats-new/2017/06/cloudwatch-events-adds-cross-account-event-delivery-support/) | [Blog](https://aws.amazon.com/blogs/aws/new-cross-account-delivery-of-cloudwatch-events/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cross-account.html) | Default bus can target a bus in another account. New `PutPermission` / `RemovePermission` APIs manage the receiving bus policy. |
| 2018-10 | Share events across all accounts in an organization | Not found (page retired) | Not found | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-bus-perms.html) | `PutPermission` with `Principal: "*"` and an `aws:PrincipalOrgID` condition grants every account in the organization. |
| 2020-11-20 | Improved resource policies for event buses | [News](https://aws.amazon.com/about-aws/whats-new/2020/11/amazon-eventbridge-announces-improved-resource-policies-for-event-buses/) | [Blog](https://aws.amazon.com/blogs/compute/simplifying-cross-account-access-with-amazon-eventbridge-resource-policies/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-bus-perms.html) | Bus policy now authorizes API calls (`PutEvents`, `PutRule`, `PutTargets`), so other accounts can publish to and create rules on a custom bus. Conditions can restrict by source, detail-type, and rule creator. |
| 2021-04-15 | Cross-region event bus targets | [News](https://aws.amazon.com/about-aws/whats-new/2021/04/amazon-eventbridge-introduces-support-cross-region-event-bus-targets/) | [Blog](https://aws.amazon.com/blogs/compute/introducing-cross-region-event-routing-with-amazon-eventbridge/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cross-region.html) | Any commercial region can route to a bus in us-east-1, us-west-2, or eu-west-1, in the same or another account. Billed as custom events. |
| 2021-11-22 | Cross-region destinations expanded | [News](https://aws.amazon.com/about-aws/whats-new/2021/11/amazon-eventbridge-cross-region-expands/) | [Blog](https://aws.amazon.com/blogs/compute/expanding-cross-region-event-routing-with-amazon-eventbridge/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cross-region.html) | All regions except AWS GovCloud (US) and China can be a cross-region destination. |

## IAM Role Requirement

This is a documentation note, not an AWS News announcement.

| Date | Scope | Source | Reference docs | Notes |
| --- | --- | --- | --- | --- |
| 2023-03-02 | New cross-account event bus targets | EventBridge User Guide | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cross-account.html) | Every new cross-account bus target needs an execution role. Targets created without a role before that date keep working. |

Key points:

- The role lives in the sender account, trusts `events.amazonaws.com`, and allows `events:PutEvents` on the receiver bus ARN.
- With a role, the sender's SCPs apply to the delivery, which enforces organization boundaries.
- The console creates the role automatically; the CLI, SDKs, and IaC do not.
- Older role-less targets are not affected but AWS recommends adding a role.

## Behaviour Indicators

| Indicator | Meaning |
| --- | --- |
| `AWS::Events::EventBusPolicy` / `PutPermission` | Receiver bus resource policy granting accounts, an organization, or everyone. |
| `aws:PrincipalOrgID` condition | Organization-wide grant on the receiver bus. |
| Rule target ARN `arn:aws:events:<region>:<other-account>:event-bus/<name>` + `RoleArn` | Sender side of bus-to-bus. |
| `account` field in receiver rule patterns | Without it, receiver rules also match events from every account allowed to send; add it when the bus accepts all accounts. `"*"` never matches. |
| Receiver forwards to a third account | Not delivered: bus-to-bus is one hop only. |
| Billing | Sender pays for the events as custom events; the receiver is not charged for the hop. |
