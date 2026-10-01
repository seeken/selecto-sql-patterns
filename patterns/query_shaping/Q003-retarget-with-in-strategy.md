# Q003 Retarget With IN Strategy

## Metadata

- Source: Selecto Retarget Tests
- Source URL: https://github.com/seeken/selecto
- Source License: MIT
- Dialect: postgres
- Tags: shaping, retarget, in-subquery

## Problem

Retarget an event-filtered query to its attendees' orders using the IN-subquery strategy.

## SQL

```sql
SELECT o.product_name, o.quantity
FROM orders AS o
WHERE o.order_id IN (
  SELECT DISTINCT o2.order_id
  FROM events AS e
  INNER JOIN attendees AS a ON a.event_id = e.event_id
  INNER JOIN orders AS o2 ON o2.attendee_id = a.attendee_id
  WHERE e.event_id = 2000
);
```

## Selecto

```elixir
query =
  Selecto.configure(event_retarget_domain(), :mock_connection, validate: false)
  |> Selecto.filter({"event_id", 2000})
  |> Selecto.retarget(:orders, strategy: :in)
  |> Selecto.select(["product_name", "quantity"])

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

Selecto.configure(event_retarget_domain(), :mock_connection, validate: false)
|> Selecto.filter(eq("event_id", 2000))
|> Selecto.retarget(:orders, strategy: :in)
|> Selecto.select(["product_name", "quantity"])
```

## Selecto Yielded SQL

```sql
select selecto_root.product_name, selecto_root.quantity
        from orders selecto_root
        where (( selecto_root.order_id in (
        select orders.order_id
        from events subq_root_events left join attendees attendees on attendees.event_id = subq_root_events.event_id left join orders orders on orders.attendee_id = attendees.attendee_id
        where (( subq_root_events.event_id = $1 ))
      ) ))
```

**Params:** `[2000]`

## Expected SQL Shape

- includes keyword: `from orders`
- includes keyword: ` in (`
- includes keyword: `from events`
- includes keyword: `join attendees`

## Notes

- `strategy: :in` is the default. It keeps the target rows whose primary key
  is in the set the context query selects through the join path.
- The context is the original query's joined read under all of its filters,
  including required filters, so a filter on `attendees` would narrow the
  result to those attendees' orders.
- The target must be table-backed and list its primary key in `fields`.
