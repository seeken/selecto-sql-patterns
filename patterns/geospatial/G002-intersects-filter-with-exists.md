# G002 Intersects Filter With EXISTS

## Metadata

- Source: PostGIS Documentation
- Source URL: https://postgis.net/docs/ST_Intersects.html
- Source License: PostgreSQL / PostGIS Documentation License
- Dialect: postgres
- Tags: geospatial, postgis, intersects, exists, escape-hatch

## Problem

Return locations that intersect at least one region geometry.

## SQL

```sql
SELECT l.id, l.name
FROM locations AS l
WHERE EXISTS (
  SELECT 1
  FROM regions AS r
  WHERE ST_Intersects(l.geom, r.geom)
)
ORDER BY l.id ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(location_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])
  |> Selecto.filter({:exists, "SELECT 1 FROM regions r WHERE ST_Intersects(selecto_root.geom, r.geom)"})
  |> Selecto.order_by({"id", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( exists (SELECT 1 FROM regions r WHERE ST_Intersects(selecto_root.geom, r.geom)) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `exists (`
- includes keyword: `st_intersects`
- includes keyword: `where`
- includes keyword: `from locations`

## Notes

- `EXISTS` keeps spatial intersection checks correlated without expanding rows.
- Raw `EXISTS` is used intentionally because this correlation uses a non-equi spatial predicate (`ST_Intersects`) against an unjoined table.
- This pattern is compatible with native filters plus a focused spatial escape hatch clause.
