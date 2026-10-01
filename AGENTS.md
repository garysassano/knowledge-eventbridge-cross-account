# AGENTS.md

This repo is a source of truth that AI agents use to choose between overlapping AWS cross-account options. Accuracy matters more than coverage: a missing row is better than a wrong one.

## Layout

- `README.md`: decision tables (Approach Matrix, Current Feature Support, When To Use What), AWS Names, the category index, and Related But Not Core.
- `docs/<category>.md`: one file per base model, in this order: one-paragraph summary, `## Timeline`, an optional notice section for non-News sources, then one `## <Name> Indicators` table.
- `scripts/check-links.sh`: checks every markdown link.

## Changing facts

- Every claim must come from an AWS source: documentation, What's New, an AWS blog, the pricing page, or an AWS-authored skill. If a cell is an inference, say so in the cell. If AWS sources disagree, record both and name them.
- Timeline rows use `| Date | Item | AWS News | AWS Blog | AWS Docs | Notes |`, sorted by date. The date is the What's New "Posted on" date in `YYYY-MM-DD`; use `YYYY-MM` only when no source gives the day.
- Write `Not found` in a link column only after searching for that source. When an AWS page has been retired, say so in Notes and give the source used for the date.
- A fact can appear in several tables (Approach Matrix, Current Feature Support, Category Timelines, a docs file). Update all of them together.
- A new base model gets its own docs file, a matrix column, an AWS Names row, and a Category Timelines row. A feature that depends on an existing model belongs in Related But Not Core.
- Bump `Last updated` in `README.md` and run `scripts/check-links.sh` before committing.

## Style

Write one sentence or paragraph per line and never hard-wrap prose. Prettier owns markdown formatting.
