# Q010 Shape With Overlay-Added Join

## Metadata

- Source: Selecto Overlay DSL
- Source URL: https://github.com/seeken/selecto
- Source License: MIT
- Dialect: postgres
- Tags: shaping, overlay, join, overlay-dsl

## Problem

Add a customer join through an overlay layer so a generated base domain can pick
up related fields without rewriting the base config.

## SQL

```sql
SELECT o.order_number, o.status, c.name
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id
ORDER BY o.order_number ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_overlay_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "status", "customer.name"])
  |> Selecto.order_by({"order_number", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

Selecto.configure(order_domain_with_overlay_customer_join(), :mock_connection, validate: false)
|> Selecto.select(["order_number", "status", "customer.name"])
|> Selecto.order_by([asc("order_number")])
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.status, customer.name
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        order by selecto_root.order_number asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `from orders`
- includes keyword: `left join`
- includes keyword: `customers customer`
- includes keyword: `order by`

## Notes

- The base domain only needs the root `customer_id`; the overlay supplies the
  source association, schema entry, and join definition.
- This keeps generator-owned base domains stable while still letting app-owned
  reporting joins evolve.
