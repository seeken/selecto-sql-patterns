# Q002 Pivot To Joined Target Schema

## Metadata

- Source: Selecto Pivot Integration Tests
- Source URL: https://github.com/seeken/selecto
- Source License: MIT
- Dialect: postgres
- Tags: shaping, pivot, exists, retargeting

## Problem

Start from event filters, then pivot the query root to related orders while preserving filter context.

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
  Selecto.configure(event_pivot_domain(), :mock_connection, validate: false)
  |> Selecto.filter({"event_id", 1000})
  |> Selecto.select(["orders.product_name", "orders.quantity"])
  |> Selecto.pivot(:orders, subquery_strategy: :exists)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select t.product_name, t.quantity
        from orders t
        where EXISTS (SELECT 1 FROM events sub_s INNER JOIN attendees j_attendees ON sub_s.event_id = j_attendees.event_id INNER JOIN orders j_orders ON j_attendees.attendee_id = j_orders.attendee_id WHERE j_orders.order_id = t.order_id AND sub_s.event_id = $1)
```

**Params:** `[1000]`

## Expected SQL Shape

- includes keyword: `from orders`
- includes keyword: `exists (`
- includes keyword: `inner join`
- includes keyword: `from events`

## Notes

- `pivot/3` retargets output to a joined schema while reusing existing root predicates.
- `subquery_strategy: :exists` emits a correlated EXISTS envelope.
