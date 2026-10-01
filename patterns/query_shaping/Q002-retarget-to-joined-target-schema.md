# Q002 Retarget To Joined Target Schema

## Metadata

- Source: Selecto Retarget Tests
- Source URL: https://github.com/seeken/selecto
- Source License: MIT
- Dialect: postgres
- Tags: shaping, retarget, exists, retargeting

## Problem

Filter events, then retarget the query to the orders their attendees placed and select order columns.

## SQL

```sql
SELECT o.product_name, o.quantity
FROM orders AS o
WHERE EXISTS (
  SELECT 1
  FROM events AS e
  INNER JOIN attendees AS a ON a.event_id = e.event_id
  INNER JOIN orders AS o2 ON o2.attendee_id = a.attendee_id
  WHERE o2.order_id = o.order_id
    AND e.event_id = 1000
);
```

## Selecto

```elixir
query =
  Selecto.configure(event_retarget_domain(), :mock_connection, validate: false)
  |> Selecto.filter({"event_id", 1000})
  |> Selecto.retarget(:orders, strategy: :exists)
  |> Selecto.select(["product_name", "quantity"])

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

Selecto.configure(event_retarget_domain(), :mock_connection, validate: false)
|> Selecto.filter(eq("event_id", 1000))
|> Selecto.retarget(:orders, strategy: :exists)
|> Selecto.select(["product_name", "quantity"])
```

## Selecto Yielded SQL

```sql
select selecto_root.product_name, selecto_root.quantity
        from orders selecto_root
        where (( exists (select 1 from (
        select orders.order_id
        from events selecto_root left join attendees attendees on attendees.event_id = selecto_root.event_id left join orders orders on orders.attendee_id = attendees.attendee_id
        where (( selecto_root.event_id = $1 ))
      ) selecto_retarget_context where selecto_retarget_context.order_id = selecto_root.order_id) ))
```

**Params:** `[1000]`

## Expected SQL Shape

- includes keyword: `from orders`
- includes keyword: `exists (`
- includes keyword: `selecto_retarget_context`
- includes keyword: `from events`

## Notes

- `retarget/3` returns a query rooted at the target join (`:orders`, or the
  path `"attendees.orders"`). Select, filter, and order after the retarget
  with target-relative names such as `"product_name"`.
- The filters set before the retarget become its context: the result is the
  distinct orders the original joined read reaches under those filters.
  Selections, ordering, grouping, and limits set before it are discarded.
- `strategy: :exists` correlates the target key with the context query as a
  derived table. It returns the same rows as the default `:in` strategy.
