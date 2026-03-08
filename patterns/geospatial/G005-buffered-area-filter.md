# G005 Buffered Area Filter

## Metadata

- Source: PostGIS Documentation
- Source URL: https://postgis.net/docs/ST_Buffer.html
- Source License: PostgreSQL / PostGIS Documentation License
- Dialect: postgres
- Tags: geospatial, postgis, buffer, intersects, escape-hatch

## Problem

Find locations that intersect a buffered radius around a reference point.

## SQL

```sql
SELECT l.id, l.name
FROM locations AS l
WHERE ST_Intersects(
  l.geom,
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.98, 40.75), 4326), 0.01)
)
ORDER BY l.id ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(location_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])
  |> Selecto.filter({
    :raw_sql_filter,
    "ST_Intersects(selecto_root.geom, ST_Buffer(ST_SetSRID(ST_MakePoint(-73.98, 40.75), 4326), 0.01))"
  })
  |> Selecto.order_by({"id", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( ST_Intersects(selecto_root.geom, ST_Buffer(ST_SetSRID(ST_MakePoint(-73.98, 40.75), 4326), 0.01)) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `st_buffer`
- includes keyword: `st_intersects`
- includes keyword: `where`
- includes keyword: `from locations`

## Notes

- Buffered area checks are useful for proximity alerts and impact zones.
- Keep spatial escape-hatch usage narrowly scoped so it can be replaced by native extensions later.
