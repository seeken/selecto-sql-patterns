# P004 Page Slices With Joined Columns

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-order.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: pagination, joins, ordering, deterministic

## Problem

Paginate order rows sorted by joined customer name and order number.

## SQL

```sql
SELECT o.order_number, c.name, o.total
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id
ORDER BY c.name ASC, o.order_number ASC
LIMIT 15 OFFSET 30;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "customer.name", "total"])
  |> Selecto.order_by({"customer.name", :asc})
  |> Selecto.order_by({"order_number", :asc})
  |> Selecto.limit(15)
  |> Selecto.offset(30)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, customer.name, selecto_root.total
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        order by customer.name asc, selecto_root.order_number asc
      
        limit 15
      
        offset 30
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `left join`
- includes keyword: `order by`
- includes keyword: `limit`
- includes keyword: `offset`

## Notes

- Include tie-breaker columns in ordering for deterministic pagination windows.
- Joined sort keys are useful for user-facing alphabetical listings.
