# CA004 Order Sequence Within Cohort

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/tutorial-window.html
- Source License: PostgreSQL License
- Dialect: ansi
- Tags: cohort-analysis, row-number, lifecycle

## Problem

Number each customer's orders in cohort-relative sequence.

## SQL

```sql
SELECT c.customer_id,
       c.cohort_start,
       o.order_number,
       o.inserted_at,
       ROW_NUMBER() OVER (
         PARTITION BY c.customer_id
         ORDER BY o.inserted_at ASC
       ) AS cohort_order_number
FROM first_order_cohorts AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
ORDER BY c.customer_id ASC, o.inserted_at ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(first_order_cohort_domain(), :mock_connection, validate: false)
  |> Selecto.select(["customer_id", "cohort_start", "orders.order_number", "orders.inserted_at"])
  |> Selecto.window_function(:row_number, [],
    over: [partition_by: ["customer_id"], order_by: [{"orders.inserted_at", :asc}]],
    as: "cohort_order_number"
  )
  |> Selecto.order_by([{"customer_id", :asc}, {"orders.inserted_at", :asc}])

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

Selecto.configure(first_order_cohort_domain(), :mock_connection, validate: false)
|> Selecto.select(["customer_id", "cohort_start", "orders.order_number", "orders.inserted_at"])
|> Selecto.window_function(:row_number, [],
  over: [partition_by: ["customer_id"], order_by: [asc("orders.inserted_at")]],
  as: "cohort_order_number"
)
|> Selecto.order_by([asc("customer_id"), asc("orders.inserted_at")])
```

## Selecto Yielded SQL

```sql
select selecto_root.customer_id, selecto_root.cohort_start, orders.order_number, orders.inserted_at, ROW_NUMBER() OVER (PARTITION BY selecto_root.customer_id ORDER BY orders.inserted_at ASC) AS "cohort_order_number"
        from first_order_cohorts selecto_root left join orders orders on orders.customer_id = selecto_root.customer_id
        order by selecto_root.customer_id asc, orders.inserted_at asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `row_number`
- includes keyword: `partition by`
- includes keyword: `cohort_start`
- includes keyword: `order by`

## Notes

- The row number can be used to compare first, second, and later orders across
  cohorts.
