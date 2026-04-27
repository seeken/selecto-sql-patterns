# E003 Distinct And Statistical Aggregates

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-aggregate.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: expressions, aggregates, count-distinct, statistics

## Problem

Report each order status with distinct customer coverage and basic dispersion
metrics for totals.

## SQL

```sql
SELECT o.status,
       COUNT(DISTINCT o.customer_id) AS distinct_customer_count,
       STDDEV(o.total) AS stddev_total,
       VARIANCE(o.total) AS variance_total
FROM orders AS o
GROUP BY o.status
ORDER BY o.status ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select([
    "status",
    {:field, {:count_distinct, "customer_id"}, "distinct_customer_count"},
    {:field, {:func, :stddev, ["total"]}, "stddev_total"},
    {:field, {:func, :variance, ["total"]}, "variance_total"}
  ])
  |> Selecto.group_by(["status"])
  |> Selecto.order_by({"status", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
|> Selecto.select([
  "status",
  as(count_distinct("customer_id"), "distinct_customer_count"),
  as(stddev("total"), "stddev_total"),
  as(variance("total"), "variance_total")
])
|> Selecto.group_by(["status"])
|> Selecto.order_by([asc("status")])
```

## Selecto Yielded SQL

```sql
select selecto_root.status, COUNT(DISTINCT selecto_root.customer_id), stddev(selecto_root.total), variance(selecto_root.total)
        from orders selecto_root
        group by selecto_root.status

        order by selecto_root.status asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `count(distinct`
- includes keyword: `stddev`
- includes keyword: `variance`
- includes keyword: `group by`

## Notes

- MSSQL uses adapter-specific names for standard deviation and variance.
- SQLite live smoke validation leaves this generated-only unless aggregate
  functions are registered in the connection.
