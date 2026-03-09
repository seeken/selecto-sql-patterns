# G008 Spatial Join With Attribute Predicates

## Metadata

- Source: PostGIS Documentation
- Source URL: https://postgis.net/docs/ST_Intersects.html
- Source License: PostgreSQL / PostGIS Documentation License
- Dialect: postgres
- Tags: geospatial, postgis, joins, predicates, escape-hatch

## Problem

Keep locations that intersect a region while constraining the region by attribute.

## SQL

```sql
SELECT l.id, l.name
FROM locations AS l
WHERE EXISTS (
  SELECT 1
  FROM regions AS r
  WHERE ST_Intersects(l.geom, r.geom)
    AND r.kind = 'delivery'
)
ORDER BY l.id ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(location_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])
  |> Selecto.filter({
    :exists,
    "SELECT 1 FROM regions r WHERE ST_Intersects(selecto_root.geom, r.geom) AND r.kind = $1",
    ["delivery"]
  })
  |> Selecto.order_by({"id", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( exists (SELECT 1 FROM regions r WHERE ST_Intersects(selecto_root.geom, r.geom) AND r.kind = $1) ))
      
        order by selecto_root.id asc
```

**Params:** `["delivery"]`

## Expected SQL Shape

- includes keyword: `exists (`
- includes keyword: `st_intersects`
- includes keyword: `$1`
- includes keyword: `from locations`

## Notes

- Attribute-constrained spatial joins are common in service-area lookups.
- Raw `EXISTS` is used intentionally because the correlation depends on `ST_Intersects(selecto_root.geom, r.geom)` plus an inner attribute predicate.
- Parameterizing the region attribute keeps this pattern reusable.
