# T008 Timestamp-Based Set Merge

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-union.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: time-series, set-operations, merge

## Problem

Merge current and archived event streams into one timestamp-ordered feed.

## SQL

```sql
(SELECT o.order_number, o.inserted_at, o.total
 FROM orders AS o)
UNION ALL
(SELECT ao.order_number, ao.inserted_at, ao.total
 FROM archived_orders AS ao)
ORDER BY inserted_at DESC
LIMIT 50;
```

## Selecto

```elixir
current_events =
  Selecto.configure(order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "inserted_at", "total"])

archived_events =
  Selecto.configure(archived_order_timeseries_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "inserted_at", "total"])

query =
  Selecto.union(current_events, archived_events, all: true)
  |> Selecto.order_by({"inserted_at", :desc})
  |> Selecto.limit(50)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
(
        select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from orders selecto_root
        order by selecto_root.inserted_at desc
      
        limit 50
      )
UNION ALL
(
        select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from archived_orders selecto_root
        order by selecto_root.inserted_at desc
      
        limit 50
      )
ORDER BY selecto_root.inserted_at desc, selecto_root.inserted_at desc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `union all`
- includes keyword: `inserted_at`
- includes keyword: `order by`
- includes keyword: `limit`

## Notes

- Time-ordered set merges are common for cold/hot storage read paths.
- Apply ordering and limits on the outer merged result.
