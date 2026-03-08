# S007 In Subquery Plus Root Filter

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, in, filtering, conjunction

## Problem

Apply a root filter and an `IN` subquery filter in one predicate tree.

## SQL

```sql
SELECT o.order_number, o.customer_id, o.total
FROM orders AS o
WHERE o.status = 'delivered'
  AND o.customer_id IN (
    SELECT c.id
    FROM customers AS c
    WHERE c.tier = 'gold'
  )
ORDER BY o.total DESC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "customer_id", "total"])
  |> Selecto.filter({"customer_id", {:subquery, :in, "SELECT id FROM customers WHERE tier = 'gold'", []}})
  |> Selecto.filter({"status", "delivered"})
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (SELECT id FROM customers WHERE tier = 'gold') ) and ( selecto_root.status = $1 ))
      
        order by selecto_root.total desc
```

**Params:** `["delivered"]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `where`
- includes keyword: ` and `
- includes keyword: `in (`

## Notes

- Demonstrates mixed predicate trees with both root and subquery conditions.
- Uses the native `IN` subquery predicate plus a root-side filter.
- Useful for reproducing common reporting filters from legacy SQL.
