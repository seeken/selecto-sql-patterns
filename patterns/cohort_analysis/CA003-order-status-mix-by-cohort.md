# CA003 Order Status Mix By Cohort

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/tutorial-join.html
- Source License: PostgreSQL License
- Dialect: ansi
- Tags: cohort-analysis, joins, status-mix

## Problem

Measure the status distribution of orders associated with each customer cohort.

## SQL

```sql
SELECT c.cohort_start,
       o.status,
       COUNT(o.id) AS order_count
FROM first_order_cohorts AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.cohort_start, o.status
ORDER BY c.cohort_start ASC, o.status ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(first_order_cohort_domain(), :mock_connection, validate: false)
  |> Selecto.select(["cohort_start", "orders.status", {:count, "orders.id"}])
  |> Selecto.group_by(["cohort_start", "orders.status"])
  |> Selecto.order_by([{"cohort_start", :asc}, {"orders.status", :asc}])

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

Selecto.configure(first_order_cohort_domain(), :mock_connection, validate: false)
|> Selecto.select(["cohort_start", "orders.status", count("orders.id")])
|> Selecto.group_by(["cohort_start", "orders.status"])
|> Selecto.order_by([asc("cohort_start"), asc("orders.status")])
```

## Selecto Yielded SQL

```sql
select selecto_root.cohort_start, orders.status, COUNT(orders.id)
        from first_order_cohorts selecto_root left join orders orders on orders.customer_id = selecto_root.customer_id
        group by selecto_root.cohort_start, orders.status

        order by selecto_root.cohort_start asc, orders.status asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `first_order_cohorts`
- includes keyword: `left join`
- includes keyword: `status`
- includes keyword: `group by`

## Notes

- Joining the cohort anchor back to events gives a compact retention-quality
  slice without leaving Selecto.
