# S009 Compare Total Against ANY Subquery

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-subquery.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: subquery, any, comparison

## Problem

Find orders whose total is below at least one reference total from delivered orders.

## SQL

```sql
SELECT o.order_number, o.status, o.total
FROM orders AS o
WHERE o.total < ANY (
  SELECT i.total
  FROM orders AS i
  WHERE i.status = 'delivered'
)
ORDER BY o.total ASC;
```

## Selecto

```elixir
delivered_totals =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["total"])
  |> Selecto.filter({"status", "delivered"})

query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "status", "total"])
  |> Selecto.filter({"total", :<, {:subquery, :any, delivered_totals}})
  |> Selecto.order_by({"total", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.total < any (
        select subq_root_orders.total
        from orders subq_root_orders
        where (( subq_root_orders.status = $1 ))
      ) ))
      
        order by selecto_root.total asc
```

**Params:** `["delivered"]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: ` any (`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- `ANY` compares against at least one row from the subquery.
- The reference totals come from a composed Selecto subquery.
- Useful for relative comparisons without hardcoded thresholds.
