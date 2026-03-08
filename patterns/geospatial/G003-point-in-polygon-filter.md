# G003 Point In Polygon Filter

## Metadata

- Source: PostGIS Documentation
- Source URL: https://postgis.net/docs/ST_Contains.html
- Source License: PostgreSQL / PostGIS Documentation License
- Dialect: postgres
- Tags: geospatial, postgis, contains, polygon, escape-hatch

## Problem

Keep only locations whose geometry lies within a polygon boundary.

## SQL

```sql
SELECT l.id, l.name
FROM locations AS l
WHERE ST_Contains(
  ST_GeomFromText('POLYGON((-74.02 40.70, -73.95 40.70, -73.95 40.78, -74.02 40.78, -74.02 40.70))', 4326),
  l.geom
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
    "ST_Contains(ST_GeomFromText('POLYGON((-74.02 40.70, -73.95 40.70, -73.95 40.78, -74.02 40.78, -74.02 40.70))', 4326), selecto_root.geom)"
  })
  |> Selecto.order_by({"id", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( ST_Contains(ST_GeomFromText('POLYGON((-74.02 40.70, -73.95 40.70, -73.95 40.78, -74.02 40.78, -74.02 40.70))', 4326), selecto_root.geom) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `st_contains`
- includes keyword: `st_geomfromtext`
- includes keyword: `where`
- includes keyword: `from locations`

## Notes

- This shape uses a raw SQL filter while first-class spatial predicates are still external.
- Keep polygon literals and SRID explicit in documentation examples.
