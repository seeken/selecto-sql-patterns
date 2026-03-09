# S003 Exists Correlated Filter

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, exists, correlated, filtering, escape-hatch

## Problem

Return orders only when a matching gold-tier customer exists.

## SQL

```sql
SELECT o.order_number, o.status, o.total
FROM orders AS o
WHERE EXISTS (
  SELECT 1
  FROM customers AS c
  WHERE c.id = o.customer_id
    AND c.tier = 'gold'
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
    "SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = 'gold'"
  })
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( exists (SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = 'gold') ))
      
        order by selecto_root.total desc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `exists (`
- includes keyword: `from customers`
- includes keyword: `order by`

## Notes

- Uses raw `{:exists, ...}` intentionally because this is a correlated predicate (`c.id = selecto_root.customer_id`).
- Current non-escape APIs can build derived-table joins, but not this correlated `EXISTS` shape directly.
- Works well when translating legacy SQL step by step.
