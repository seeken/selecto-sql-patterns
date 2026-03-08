# C003 Batch With CTEs Auto Join

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: cte, with, multi-cte, joins

## Problem

Attach multiple CTEs in one pass and auto-join each to the root query.

## SQL

```sql
WITH
  order_totals (id, total) AS (
    SELECT o.id, o.total
    FROM orders AS o
  ),
  customer_spend (customer_id, total) AS (
    SELECT o.customer_id, o.total
    FROM orders AS o
  )
SELECT
  o.order_number,
  ot.total,
  cs.total
FROM orders AS o
LEFT JOIN order_totals AS ot ON ot.id = o.id
LEFT JOIN customer_spend AS cs ON cs.customer_id = o.customer_id;
```

## Selecto

```elixir
order_totals_cte =
  Selecto.Advanced.CTE.create_cte(
    "order_totals",
    fn ->
      Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
      |> Selecto.select(["id", "total"])
    end,
    columns: ["id", "total"]
  )

customer_spend_cte =
  Selecto.Advanced.CTE.create_cte(
    "customer_spend",
    fn ->
      Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
      |> Selecto.select(["customer_id", "total"])
    end,
    columns: ["customer_id", "total"]
  )

query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.with_ctes([order_totals_cte, customer_spend_cte], joins: true)
  |> Selecto.select(["order_number", "order_totals.total", "customer_spend.total"])

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
WITH customer_spend (customer_id, total) AS (
    
        select selecto_root.customer_id, selecto_root.total
        from orders selecto_root
),
    order_totals (id, total) AS (
    
        select selecto_root.id, selecto_root.total
        from orders selecto_root
)

        select selecto_root.order_number, order_totals.total, customer_spend.total
        from orders selecto_root left join order_totals order_totals on order_totals.id = selecto_root.id left join customer_spend customer_spend on customer_spend.customer_id = selecto_root.customer_id
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `with`
- includes keyword: `left join`
- includes keyword: `order_totals`
- includes keyword: `customer_spend`

## Notes

- `with_ctes/3` helps compose larger query graphs with deterministic join wiring.
- `joins: true` auto-joins each CTE by inferring keys/fields from declared columns.
