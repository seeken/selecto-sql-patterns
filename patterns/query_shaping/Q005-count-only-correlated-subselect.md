# Q005 Count-Only Correlated Subselect

## Metadata

- Source: Selecto Subselect Integration Tests
- Source URL: https://github.com/seeken/selecto
- Source License: MIT
- Dialect: postgres
- Tags: shaping, subselect, count

## Problem

Return attendee rows with a correlated count of related orders.

## SQL

```sql
SELECT a.name,
       a.email,
       (
         SELECT COUNT(o.order_id)
         FROM orders AS o
         WHERE o.attendee_id = a.attendee_id
       ) AS order_count
FROM attendees AS a
ORDER BY a.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(attendee_domain_with_orders_join(), :mock_connection, validate: false)
  |> Selecto.select(["name", "email"])
  |> Selecto.subselect([
    %{
      fields: ["order_id"],
      target_schema: :orders,
      format: :count,
      alias: "order_count"
    }
  ])
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.email, (SELECT count(*) FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "order_count"
        from attendees selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `count(`
- includes keyword: `order_count`
- includes keyword: `from orders`
- includes keyword: `where`

## Notes

- Count-only subselects avoid join fanout while still exposing relationship size.
- This is useful for badges, summaries, and sorting by child-record count.
