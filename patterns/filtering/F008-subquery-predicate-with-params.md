# F008 Subquery Predicate With Params

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: filtering, subquery, params

## Problem

Apply a parameterized `IN` subquery filter together with a root predicate.

## SQL

```sql
SELECT o.order_number, o.customer_id, o.total
FROM orders AS o
WHERE o.customer_id IN (
  SELECT c.id
  FROM customers AS c
  WHERE c.tier = 'platinum'
)
  AND o.status = 'processing'
ORDER BY o.total DESC;
```

## Selecto

```elixir
platinum_customers =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id"])
  |> Selecto.filter({"tier", "platinum"})

query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "customer_id", "total"])
  |> Selecto.filter({"customer_id", {:subquery, :in, platinum_customers}})
  |> Selecto.filter({"status", "processing"})
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (
        select selecto_root.id
        from customers selecto_root
        where (( selecto_root.tier = $1 ))
      ) ) and ( selecto_root.status = $2 ))
      
        order by selecto_root.total desc
```

**Params:** `["platinum", "processing"]`

## Expected SQL Shape

- includes keyword: ` in (`
- includes keyword: `$1`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- Uses a constructed Selecto subquery instead of embedding SQL text.
- Combining root and subquery predicates captures common reporting patterns.
