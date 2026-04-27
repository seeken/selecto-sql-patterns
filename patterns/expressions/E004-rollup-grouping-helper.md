# E004 Rollup Grouping Helper

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-GROUPING-SETS
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: expressions, rollup, grouping

## Problem

Produce detailed order counts plus subtotal rows over customer tier and order
status using a single grouping expression.

## SQL

```sql
SELECT c.tier,
       o.status,
       COUNT(*) AS order_count
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id
GROUP BY ROLLUP (c.tier, o.status)
ORDER BY c.tier ASC, o.status ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["customer.tier", "status", {:field, {:count, "*"}, "order_count"}])
  |> Selecto.group_by(rollup: ["customer.tier", "status"])
  |> Selecto.order_by([{"customer.tier", :asc}, {"status", :asc}])

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
|> Selecto.select(["customer.tier", "status", as(count("*"), "order_count")])
|> Selecto.group_by(group_by([rollup([customer.tier, status])]))
|> Selecto.order_by([asc("customer.tier"), asc("status")])
```

## Selecto Yielded SQL

```sql
select * from (
        select customer.tier, selecto_root.status, count(*)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        group by rollup( customer.tier, selecto_root.status )
      ) as rollupfix
        order by 1 asc nulls first, 2 asc nulls first
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `rollup`
- includes keyword: `count(*)`
- includes keyword: `group by`
- includes keyword: `order by`

## Notes

- Adapters that do not support rollup can fall back to plain grouping.
- Use `group_by([rollup(...)])` when a subtotal hierarchy belongs in SQL.
