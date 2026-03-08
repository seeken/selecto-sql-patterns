# G006 Nearest-Neighbor Ordering

## Metadata

- Source: PostGIS Documentation
- Source URL: https://postgis.net/docs/ST_Distance.html
- Source License: PostgreSQL / PostGIS Documentation License
- Dialect: postgres
- Tags: geospatial, postgis, distance, ordering, escape-hatch

## Problem

Order locations by distance to a reference point.

## SQL

```sql
SELECT l.id,
       l.name,
       ST_Distance(l.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326)) AS distance
FROM locations AS l
ORDER BY ST_Distance(l.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326)) ASC
LIMIT 10;
```

## Selecto

```elixir
distance_expr =
  "ST_Distance(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326))"

query =
  Selecto.configure(location_domain(), :mock_connection, validate: false)
  |> Selecto.select([
    "id",
    "name",
    {:field, {:raw_sql, distance_expr}, "distance"}
  ])
  |> Selecto.order_by({{:raw_sql, distance_expr}, :asc})
  |> Selecto.limit(10)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.name, ST_Distance(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326))
        from locations selecto_root
        order by ST_Distance(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326)) asc
      
        limit 10
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `st_distance`
- includes keyword: `order by`
- includes keyword: `limit`
- includes keyword: `from locations`

## Notes

- Nearest-neighbor ordering is foundational for location search.
- Keep distance expression centralized to avoid drift between select and sort.
