# W009 Percent Rank By Total

## Metadata

- Source: Structured Query Language (Wikibooks)
- Source URL: https://en.wikibooks.org/wiki/Structured_Query_Language/Window_functions
- Source License: CC BY-SA 4.0
- Dialect: postgres
- Tags: windows, percent-rank, ranking

## Problem

Compute relative order-total rank as a percent scale across all rows.

## SQL

```sql
SELECT
  o.order_number,
  o.total,
  PERCENT_RANK() OVER (ORDER BY o.total DESC) AS total_percent_rank
FROM orders AS o;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "total"])
  |> Selecto.window_function(:percent_rank, [],
    over: [order_by: [{"total", :desc}]],
    as: "total_percent_rank"
  )

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.total, PERCENT_RANK() OVER (ORDER BY selecto_root.total DESC) AS total_percent_rank
        from orders selecto_root
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `percent_rank`
- includes keyword: `over`
- includes keyword: `order by`

## Notes

- `PERCENT_RANK` is useful for percentile-style segmentation.
- Unlike discrete ranks, this yields a normalized 0..1 measure.
