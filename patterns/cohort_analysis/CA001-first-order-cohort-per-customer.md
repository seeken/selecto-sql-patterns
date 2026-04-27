# CA001 First Order Cohort Per Customer

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-aggregate.html
- Source License: PostgreSQL License
- Dialect: ansi
- Tags: cohort-analysis, first-event, aggregate

## Problem

Find each customer's first observed order timestamp as the start of their
cohort.

## SQL

```sql
SELECT o.customer_id,
       MIN(o.inserted_at) AS cohort_start
FROM orders AS o
WHERE o.customer_id IS NOT NULL
GROUP BY o.customer_id
ORDER BY o.customer_id ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select(["customer_id", {:field, {:func, "MIN", ["inserted_at"]}, "cohort_start"}])
  |> Selecto.filter({"customer_id", :not_null})
  |> Selecto.group_by(["customer_id"])
  |> Selecto.order_by({"customer_id", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
|> Selecto.select(["customer_id", as(min("inserted_at"), "cohort_start")])
|> Selecto.filter(not_null("customer_id"))
|> Selecto.group_by(["customer_id"])
|> Selecto.order_by([asc("customer_id")])
```

## Selecto Yielded SQL

```sql
select selecto_root.customer_id, MIN(selecto_root.inserted_at)
        from orders selecto_root
        where (( selecto_root.customer_id is not null ))

        group by selecto_root.customer_id

        order by selecto_root.customer_id asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `min`
- includes keyword: `customer_id`
- includes keyword: `group by`
- includes keyword: `order by`

## Notes

- This pattern produces the first-event cohort anchor used by later examples.
