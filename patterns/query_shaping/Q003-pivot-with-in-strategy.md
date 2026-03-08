# Q003 Pivot With IN Strategy

## Metadata

- Source: Selecto Pivot Integration Tests
- Source URL: https://github.com/seeken/selecto
- Source License: MIT
- Dialect: postgres
- Tags: shaping, pivot, in-subquery

## Problem

Retarget an event-filtered query to orders using the pivot IN-subquery strategy.

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
  Selecto.configure(event_pivot_domain(), :mock_connection, validate: false)
  |> Selecto.filter({"event_id", 2000})
  |> Selecto.select(["orders.product_name", "orders.quantity"])
  |> Selecto.pivot(:orders, subquery_strategy: :in)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select t.product_name, t.quantity
        from orders t
        where t.order_id IN (SELECT DISTINCT j2.order_id FROM events s JOIN attendees j1 ON s.event_id = j1.event_id JOIN orders j2 ON j1.attendee_id = j2.attendee_id WHERE s.event_id = $1)
```

**Params:** `[2000]`

## Expected SQL Shape

- includes keyword: `from orders`
- includes keyword: ` in (`
- includes keyword: `from events`
- includes keyword: `join attendees`

## Notes

- `subquery_strategy: :in` produces an ID-set membership pivot shape.
- This strategy works well when target primary keys are natural correlation anchors.
