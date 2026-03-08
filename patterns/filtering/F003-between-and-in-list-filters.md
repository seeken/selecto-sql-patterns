# F003 Between And IN-List Filters

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-comparisons.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: filtering, between, in-list, ranges

## Problem

Filter orders to a target total range and a constrained set of statuses.

## SQL

```sql
SELECT o.order_number, o.status, o.total
FROM orders AS o
WHERE o.total BETWEEN 100 AND 500
  AND o.status IN ('processing', 'shipped', 'delivered')
ORDER BY o.order_number ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "status", "total"])
  |> Selecto.filter({"total", {:between, 100, 500}})
  |> Selecto.filter({"status", {:in, ["processing", "shipped", "delivered"]}})
  |> Selecto.order_by({"order_number", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.total between $1 and $2 ) and ( selecto_root.status = ANY($3) ))
      
        order by selecto_root.order_number asc
```

**Params:** `[100, 500, ["processing", "shipped", "delivered"]]`

## Expected SQL Shape

- includes keyword: `between`
- includes keyword: `any(`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- `{:between, min, max}` emits a SQL `BETWEEN` clause for numeric fields.
- For Postgres, `{:in, list}` compiles to `= ANY($n)`.
