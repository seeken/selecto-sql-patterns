# Escape Hatch Guide

Use this guide for patterns that rely on raw SQL snippets or lateral joins.

## When To Use

- Use standard Selecto APIs first (`join_subquery`, `with_cte`, `with_values`, normal filters).
- Use `lateral_join` only when the joined query shape is naturally lateral.
- Use raw SQL snippets only for constructs that are not yet ergonomic in Selecto.

## Required Rules

- Keep raw SQL snippets minimal and colocated with the pattern that needs them.
- Never interpolate untrusted values into SQL strings.
- Pass dynamic values as bind params (`$1`, `$2`, ...).
- Prefer stable alias names for lateral joins and raw selector refs.
- Tag pattern metadata with `escape-hatch` for discoverability.

## Verification Checklist

- Verify every escape-hatch pattern with `Selecto.to_sql/1`.
- Assert key SQL fragments case-insensitively in `scripts/verify_examples.exs`.
- Assert bind placeholder presence when params are expected.
- Keep root query predicates and raw predicates logically separated.

## Explicit Escape-Hatch Usage

```elixir
# Raw projection for lateral alias fields (currently required)
{:field, {:raw_sql, "delivered_stats.count"}, "delivered_order_count"}

# Parameterized raw EXISTS (only when no non-escape equivalent exists)
{:exists, "SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = $1", ["gold"]}
```
