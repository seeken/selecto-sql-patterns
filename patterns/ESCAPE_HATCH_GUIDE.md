# Escape Hatch Guide

Use this guide for patterns that rely on raw SQL snippets or lateral joins.

## When To Use

- Use standard Selecto APIs first (`join_subquery`, `with_cte`, `with_values`, normal filters).
- Use `lateral_join` only when the joined query shape is naturally lateral.
- Use raw SQL snippets only for constructs that are not yet ergonomic in Selecto.

## Required Rules

- Keep reusable raw snippets in `scripts/support/escape_hatch_helpers.exs`.
- Never interpolate untrusted values into SQL strings.
- Pass dynamic values as bind params (`$1`, `$2`, ...).
- Prefer stable alias names for lateral joins and raw selector refs.
- Tag pattern metadata with `escape-hatch` for discoverability.

## Verification Checklist

- Verify every escape-hatch pattern with `Selecto.to_sql/1`.
- Assert key SQL fragments case-insensitively in `scripts/verify_examples.exs`.
- Assert bind placeholder presence when params are expected.
- Keep root query predicates and raw predicates logically separated.

## Helper Usage

```elixir
alias SelectoSqlPatterns.EscapeHatchHelpers, as: EscapeHatch

# Raw projection for lateral alias fields
EscapeHatch.lateral_alias_field("delivered_stats", "count", "delivered_order_count")

# Correlated EXISTS snippets
{:exists, EscapeHatch.exists_gold_customer_sql()}
{:exists, EscapeHatch.exists_customer_tier_sql(), ["gold"]}
```
