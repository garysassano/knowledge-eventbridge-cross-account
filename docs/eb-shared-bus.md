# EB Shared Bus

Enhanced custom event bus shared across accounts with AWS RAM, where publishers write directly and each consumer account owns its Subscribers. Use this for a central organization-wide event backbone; existing buses are now "Custom event bus – classic".

## Timeline

| Date | Item | AWS News | AWS Blog | AWS Docs | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-09-24 | Enhanced custom event buses | [News](https://aws.amazon.com/about-aws/whats-new/2026/09/eventbridge-relaunches-custom-event-buses/) | [Blog](https://aws.amazon.com/blogs/aws/introducing-enhanced-custom-event-buses-in-amazon-eventbridge-for-enterprise-scale-event-driven-applications/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-custom-bus-sharing.html) | RAM sharing, Subscriber resource, `EventGroupId` ordering, content-based deduplication, 24 h to 1 year retention and replay, and per-KB pricing. Launched in 14 regions: us-east-1, us-east-2, us-west-2, eu-west-1, eu-central-1, eu-north-1, eu-south-2, ap-northeast-1, ap-southeast-1, ap-southeast-2, ap-southeast-5, ap-southeast-7, ap-south-1, ap-east-1. |

## Shared Bus Indicators

| Indicator | Meaning |
| --- | --- |
| `arn:aws:events:<region>:<account>:event-busv2/<name>/<id>` | Enhanced bus ARN. |
| `AWS::EventsV2::*` | CloudFormation resource types for the enhanced bus. |
| RAM resource type `events:event-busv2` | Shareable bus; in-org principals associate automatically, outside accounts must accept an invitation. |
| `AWSRAMEventBridgeEventBusV2PublishOnly` | RAM managed permission for publishers. |
| `AWSRAMEventBridgeEventBusV2SubscribeOnly` | RAM managed permission for consumers creating Subscribers. |
| `AWSRAMEventBridgeEventBusV2FullAccess` | RAM managed permission for the full consumer surface. |
| `AWSRAMEventBridgeEventBusV2EventSourceAccess` | RAM managed permission for attaching managed event sources only. |
| `default` and `AWS_RAM` bus policies | Hand-written and RAM-managed policies; an explicit `Deny` in either wins. |
| `eventsv2` CLI / `eventbridgev2` SDK | Enhanced bus API. IAM actions are still `events:*`. |
| `RevokeResource` | Bus owner withdraws a consumer's Subscriber or event source. |
| `AWS/EventsV2` `PublisherAccount` dimension | Per-publisher ingress metrics on a shared bus. |
| Billing | Per-KB pricing (rounded up to 1 KB): publisher pays ingress, Subscriber owner pays egress, bus owner pays storage. JSONata, deduplication, and schema deserialization are billed separately as event evaluation. |
