# G001 Distance Filter ST_DWithin

## Metadata

- Source: PostGIS Documentation
- Source URL: https://postgis.net/docs/ST_DWithin.html
- Source License: PostgreSQL / PostGIS Documentation License
- Dialect: postgres
- Tags: geospatial, postgis, distance, escape-hatch

## Problem

Filter locations to those within 1000 meters of a reference point.

## SQL

```sql
SELECT l.id, l.name
FROM locations AS l
WHERE ST_DWithin(
  l.geom,
  ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326),
  1000
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
    "ST_DWithin(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326), 1000)"
  })
  |> Selecto.order_by({"id", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( ST_DWithin(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326), 1000) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `st_dwithin`
- includes keyword: `where`
- includes keyword: `order by`
- includes keyword: `from locations`

## Notes

- This uses an escape-hatch filter because Selecto core does not yet expose first-class spatial predicates.
- Keep geospatial escape-hatch usage small and isolated so future native APIs can replace it cleanly.
