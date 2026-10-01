# Knowledge: EventBridge Cross-Account

Last updated: 2026-10-01

Agent-oriented reference notes for overlapping EventBridge cross-account / cross-region event delivery options and the announcements behind them.

## Contents

- [Approach Matrix](#approach-matrix)
- [Current Feature Support](#current-feature-support)
- [When To Use What](#when-to-use-what)
- [Category Timelines](#category-timelines)
- [Related But Not Core](#related-but-not-core)

## Approach Matrix

| Capability | EB Bus-to-Bus | EB Direct Targets | EB Shared Bus |
| --- | --- | --- | --- |
| Recommendation | Use for cross-region routing, or when the receiver wants its own bus, rules, and archive | Use for classic buses delivering to another team's queue/function/topic in the same region | Use for new org-wide event backbones in supported regions |
| Primary purpose | Forward events from a bus in one account to a bus in another | Deliver events from a bus straight to an AWS service in another account | One central bus that many accounts publish to and subscribe on |
| Main mechanism | Rule target = remote bus ARN, plus bus resource policy and sender execution role | Rule target = remote resource ARN, plus sender execution role and target resource policy | AWS RAM share of an `event-busv2`, with publishers calling it directly and consumers owning Subscribers |
| Bus type | Custom event bus – classic / default bus | Custom event bus – classic / default bus | Custom event bus (enhanced, `eventsv2` API) |
| Receiver needs EventBridge resources | ✅ bus + rules | ❌ only a resource policy on the target | ❌ bus is shared in; consumer creates Subscribers |
| Cross-account | ✅ | ✅ | ✅ |
| Cross-region | ✅ | ❌ same region only | ❌ regional bus; Subscriber targets must be in the Subscriber's own region and account |
| Org-wide grant | ✅ `aws:PrincipalOrgID` in bus policy | ✅ `aws:PrincipalOrgID`/`aws:ResourceOrgID` in target policy or SCP | ✅ RAM share to organization or OU |
| Ordering / retention / replay | ❌ (archive and replay are per bus) | ❌ | ✅ `EventGroupId` FIFO, 1–365 day retention, replay via Subscriber starting position |
| Who pays | Sender, as custom events; the receiving bus is not charged for the hop | Sender | Publisher pays ingestion, Subscriber owner pays delivery, bus owner pays retention |
| Good for | Regional aggregation, security/audit hubs, receiver-controlled routing | Removing the intermediate bus or Lambda/SNS bridge | Platform teams, high fan-out, chargeback, ordered or replayable streams |

## Current Feature Support

| Feature | EB Bus-to-Bus | EB Direct Targets | EB Shared Bus |
| --- | --- | --- | --- |
| Target: event bus | ✅ | n/a (that is EB Bus-to-Bus) | ✅ a classic bus is a valid Subscriber target |
| Target: SQS / SNS / Lambda / Kinesis Data Streams / API Gateway | Via rules on the receiving bus | ✅ | ✅ in the Subscriber's own account |
| Target: any other EventBridge target type | Via rules on the receiving bus | ❌ only targets with resource-based policies | ✅ 250+ services, including universal targets |
| Cross-region | ✅ all regions except GovCloud (US) and China as destinations | ❌ | ❌ |
| GovCloud (US) | ✅ | ✅ since 2025-04-25 | ❌ 14 commercial launch regions |
| Receiver-side filtering | ✅ rules on receiving bus | ❌ sender's rule decides | ✅ Subscriber filter owned by consumer |
| Transitive forwarding to a third account | ❌ events are not forwarded on again | n/a | n/a |
| Central visibility of who consumes what | ❌ | ❌ | ✅ bus owner sees all Subscribers and can `RevokeResource` |

EB Direct Targets does not replace EB Bus-to-Bus: it is same-region only and supports only five target types. EB Shared Bus is a separate resource type with a separate API namespace (`eventsv2`) and does not change existing classic buses, which AWS says keep working unchanged.

## When To Use What

| Requirement | Prefer |
| --- | --- |
| Send events to a team's SQS/SNS/Lambda/Kinesis/API Gateway in another account, same region | EB Direct Targets |
| Aggregate events from many regions into one region | EB Bus-to-Bus |
| Receiver wants to own filtering, archive/replay, or further routing | EB Bus-to-Bus |
| New central event backbone shared across the organization | EB Shared Bus |
| Ordered delivery, dedup, or replay without a separate archive | EB Shared Bus |
| Per-team cost allocation for publishers and consumers | EB Shared Bus |
| Forward AWS service events (default bus) from member accounts to a security/audit account | EB Bus-to-Bus (or EB Direct Targets if the sink is an SQS/Lambda in the same region) |
| Regional failover of event ingestion | Global endpoints (see [Related But Not Core](#related-but-not-core)) |
| Workload in a region the enhanced bus has not launched in | EB Bus-to-Bus / EB Direct Targets |

## Category Timelines

| Category | File | Introduced | Notes |
| --- | --- | --- | --- |
| EB Bus-to-Bus | [docs/eb-bus-to-bus.md](docs/eb-bus-to-bus.md) | 2017-06-30 cross-account, 2021-04-15 cross-region | Original CloudWatch Events cross-account model. Organization grants in 2018, resource policy authorization in 2020, execution role required for new targets from 2023-03-02. |
| EB Direct Targets | [docs/eb-direct-targets.md](docs/eb-direct-targets.md) | 2025-01-21 | Classic bus delivers straight to SQS, SNS, Lambda, Kinesis Data Streams, or API Gateway in another account, same region. GovCloud (US) on 2025-04-25. |
| EB Shared Bus | [docs/eb-shared-bus.md](docs/eb-shared-bus.md) | 2026-09-24 | Enhanced custom event bus shared through AWS RAM. Existing buses renamed "Custom event bus – classic". |

## Related But Not Core

These are not extra base models. They are related EventBridge capabilities layered on top of, or next to, the core models above.

| Date | Item | AWS News | AWS Blog | AWS Docs | Notes |
| --- | --- | --- | --- | --- | --- |
| 2021-05-19 | Bus-to-bus in the same account and region | [News](https://aws.amazon.com/about-aws/whats-new/2021/05/amazon-eventbridge-supports-sharing-events-between-event-buses-same-account-region/) | [Blog](https://aws.amazon.com/blogs/compute/using-bus-to-bus-event-routing-with-amazon-eventbridge/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-bus-to-bus.html) | Not cross-account. Same no-transitive-forwarding rule: bus 1 → bus 2 → bus 3 in one account does not reach bus 3. |
| 2021-09-03 | Cross-account schema discovery | [News](https://aws.amazon.com/about-aws/whats-new/2021/09/cross-account-discovery-amazon-eventbridge-schema/) | Not found | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-schema.html) | Schema discovery on a receiving classic bus now also generates schemas for events sent from other accounts. Pairs with EB Bus-to-Bus. Registries can also be shared with [resource-based policies](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-resource-based-schemas.html). |
| 2022-04-07 | Global endpoints | [News](https://aws.amazon.com/about-aws/whats-new/2022/04/amazon-eventbridge-global-endpoints-automatic-failover-recovery/) | [Blog](https://aws.amazon.com/blogs/compute/introducing-global-endpoints-for-amazon-eventbridge/) | [Docs](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-global-endpoints.html) | Cross-region failover of ingestion, not cross-account: custom buses must have the same name in the same account in both regions. Replication uses managed rules. |
