# T011 Previous Order Timestamp Per Customer

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/tutorial-window.html
- Source License: PostgreSQL License
- Dialect: ansi
- Tags: time-series, lag, customer-history

## Problem

Show each customer's previous order timestamp beside every order event.

## SQL

```sql
SELECT o.customer_id,
       o.order_number,
       o.inserted_at,
       LAG(o.inserted_at, 1) OVER (
         PARTITION BY o.customer_id
         ORDER BY o.inserted_at ASC
       ) AS previous_order_at
FROM orders AS o
WHERE o.customer_id IS NOT NULL
ORDER BY o.customer_id ASC, o.inserted_at ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select(["customer_id", "order_number", "inserted_at"])
  |> Selecto.filter({"customer_id", :not_null})
  |> Selecto.window_function(:lag, ["inserted_at", 1],
    over: [partition_by: ["customer_id"], order_by: [{"inserted_at", :asc}]],
    as: "previous_order_at"
  )
  |> Selecto.order_by([{"customer_id", :asc}, {"inserted_at", :asc}])

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
|> Selecto.select(["customer_id", "order_number", "inserted_at"])
|> Selecto.filter(not_null("customer_id"))
|> Selecto.window_function(:lag, ["inserted_at", 1],
  over: [partition_by: ["customer_id"], order_by: [asc("inserted_at")]],
  as: "previous_order_at"
)
|> Selecto.order_by([asc("customer_id"), asc("inserted_at")])
```

## Selecto Yielded SQL

```sql
select selecto_root.customer_id, selecto_root.order_number, selecto_root.inserted_at, LAG(selecto_root.inserted_at) OVER (PARTITION BY selecto_root.customer_id ORDER BY selecto_root.inserted_at ASC) AS "previous_order_at"
        from orders selecto_root
        where (( selecto_root.customer_id is not null ))

        order by selecto_root.customer_id asc, selecto_root.inserted_at asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `lag(`
- includes keyword: `partition by`
- includes keyword: `customer_id`
- includes keyword: `order by`

## Notes

- This is the basis for order-gap and repeat-purchase interval calculations.
