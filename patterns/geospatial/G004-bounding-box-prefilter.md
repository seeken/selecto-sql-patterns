# G004 Bounding Box Prefilter

## Metadata

- Source: PostGIS Documentation
- Source URL: https://postgis.net/docs/ST_MakeEnvelope.html
- Source License: PostgreSQL / PostGIS Documentation License
- Dialect: postgres
- Tags: geospatial, postgis, bounding-box, prefilter, escape-hatch

## Problem

Apply a fast bounding-box prefilter before more expensive spatial checks.

## SQL

```sql
SELECT l.id, l.name
FROM locations AS l
WHERE l.geom && ST_MakeEnvelope(-74.05, 40.68, -73.90, 40.82, 4326)
ORDER BY l.id ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(location_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])
  |> Selecto.filter({
    :raw_sql_filter,
    "selecto_root.geom && ST_MakeEnvelope(-74.05, 40.68, -73.90, 40.82, 4326)"
  })
  |> Selecto.order_by({"id", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( selecto_root.geom && ST_MakeEnvelope(-74.05, 40.68, -73.90, 40.82, 4326) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `&&`
- includes keyword: `st_makeenvelope`
- includes keyword: `where`
- includes keyword: `from locations`

## Notes

- Bounding-box operators are useful coarse filters for spatial workloads.
- Pair this with precise predicates in follow-up filtering stages when needed.
