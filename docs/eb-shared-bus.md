# EB Shared Bus

The enhanced "Custom event bus": a separate resource with its own API (`eventsv2`) that one account creates and shares with the organization through AWS RAM. Publishers in other accounts write to it directly, and consumers create their own Subscribers on it. This removes bus-to-bus hops and cross-account rule wiring. Existing buses are unchanged and are now called "Custom event bus – classic".

## Timeline

| Date | Item | AWS News | AWS Blog | AWS Docs | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-09-24 | Enhanced custom event buses | [News](https://aws.amazon.com/about-aws/whats-new/2026/09/eventbridge-relaunches-custom-event-buses/) | [Blog](https://aws.amazon.com/blogs/aws/introducing-enhanced-custom-event-buses-in-amazon-eventbridge-for-enterprise-scale-event-driven-applications/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-custom-bus-what-is.html) | RAM sharing, Subscriber resource, `EventGroupId` ordering, content-based dedup, 24 h–1 year retention and replay, CloudEvents, Avro/Protobuf, and throughput (per-KB) pricing. Launch regions: us-east-1, us-east-2, us-west-2, eu-west-1, eu-central-1, eu-north-1, eu-south-2, ap-northeast-1, ap-southeast-1, ap-southeast-2, ap-southeast-5, ap-southeast-7, ap-south-1, ap-east-1. |

## Sharing

| Situation | Use |
| --- | --- |
| Consumer accounts inside the organization | RAM share; in-org principals associate automatically. |
| Account outside the organization | RAM invitation, which must be accepted within 12 hours; or a bus resource policy. |
| Explicit `Deny`, condition keys, or a narrower grant | Bus resource policy, alone or next to the RAM share. |

The consumer's own identity policy must also allow the actions: access exists only where the bus-side grant and the caller's policy intersect.

| RAM managed permission | Grants |
| --- | --- |
| `AWSRAMEventBridgeEventBusV2PublishOnly` | Publishing; signature action `events:PutRawEvents`. Read exact actions back with RAM `GetPermission`. |
| `AWSRAMEventBridgeEventBusV2SubscribeOnly` | Creating Subscribers (`events:CreateSubscriber`). |
| `AWSRAMEventBridgeEventBusV2FullAccess` | Full consumer surface, including Subscribers and event sources. |
| `AWSRAMEventBridgeEventBusV2EventSourceAccess` | Attaching managed event sources only. |

## Who Pays

| Dimension | Billed to |
| --- | --- |
| Ingestion (per KB, rounded up) | Account that made the publish call |
| Delivery (per KB, rounded up) | Account that owns the Subscriber |
| Retention | Account that owns the bus |
| Enriched operations (JSONata, dedup, schema deserialization) | Per operation |

A bus-to-bus hop from the shared bus into a team's own bus adds a delivery plus a second ingestion and retention. Subscribe directly unless the team needs its own retention, replay window, or access control.

## Resource Indicators

| Indicator | Meaning |
| --- | --- |
| `arn:aws:events:<region>:<account>:event-busv2/<name>/<id>` | Enhanced bus ARN. Store the full ARN: recreating a bus with the same name gives a new id. |
| `AWS::EventsV2::*` | CloudFormation resource types for the enhanced bus. |
| RAM resource type `events:event-busv2` | Shareable bus. |
| `aws eventsv2` / `eventbridgev2` SDK clients | Enhanced bus API. IAM actions are still `events:*`; `eventsv2:*` in a policy grants nothing. |
| `default` and `AWS_RAM` bus policies | Hand-written policy and RAM-managed policy; an explicit `Deny` in either wins. |
| `RevokeResource` | Bus owner withdraws a consumer's Subscriber or event source. Terminal and per resource; to block an account, also deny `events:CreateSubscriber` / `events:CreateEventSource` in the bus policy. |
| `AWS/EventsV2` metrics with `PublisherAccount` dimension | Per-publisher ingress on a shared bus. |
| Subscriber `InvokeConfiguration.RoleArn` | Must belong to the Subscriber's account; the target ARN must be in that same account and region. |
