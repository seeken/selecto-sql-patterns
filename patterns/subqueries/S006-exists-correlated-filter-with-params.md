# S006 Exists Correlated Filter With Params

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, exists, correlated, parameters, escape-hatch

## Problem

Use a correlated `EXISTS` subquery with bind parameters.

## SQL

```sql
SELECT o.order_number, o.status, o.total
FROM orders AS o
WHERE EXISTS (
  SELECT 1
  FROM customers AS c
  WHERE c.id = o.customer_id
    AND c.tier = $1
)
ORDER BY o.total DESC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "status", "total"])
  |> Selecto.filter({
    :exists,
    "SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = $1",
    ["gold"]
  })
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( exists (SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = $1) ))
      
        order by selecto_root.total desc
```

**Params:** `["gold"]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `exists (`
- includes keyword: `$1`
- includes keyword: `order by`

## Notes

- Uses raw `{:exists, query, params}` intentionally because this is a correlated subquery against `selecto_root.customer_id`.
- A composed subquery can express uncorrelated sets, but not this correlated `EXISTS` predicate directly today.
- Parameters from the subquery are appended to the final params list.
