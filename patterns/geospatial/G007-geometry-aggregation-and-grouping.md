# G007 Geometry Aggregation And Grouping

## Metadata

- Source: PostGIS Documentation
- Source URL: https://postgis.net/docs/ST_GeometryType.html
- Source License: PostgreSQL / PostGIS Documentation License
- Dialect: postgres
- Tags: geospatial, postgis, grouping, aggregation, escape-hatch

## Problem

Group spatial rows by geometry type and count each group.

## SQL

```sql
SELECT ST_GeometryType(l.geom) AS geom_type,
       COUNT(*) AS location_count
FROM locations AS l
GROUP BY ST_GeometryType(l.geom)
ORDER BY ST_GeometryType(l.geom) ASC;
```

## Selecto

```elixir
geom_type_expr = "ST_GeometryType(selecto_root.geom)"

query =
  Selecto.configure(location_domain(), :mock_connection, validate: false)
  |> Selecto.select([
    {:field, {:raw_sql, geom_type_expr}, "geom_type"},
    {:count, "*"}
  ])
  |> Selecto.group_by([{:raw_sql, geom_type_expr}])
  |> Selecto.order_by({{:raw_sql, geom_type_expr}, :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select ST_GeometryType(selecto_root.geom), count(*)
        from locations selecto_root
        group by ST_GeometryType(selecto_root.geom)
      
        order by ST_GeometryType(selecto_root.geom) asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `st_geometrytype`
- includes keyword: `count`
- includes keyword: `group by`
- includes keyword: `order by`

## Notes

- Geometry-type grouping is useful for data quality and schema profiling.
- Raw SQL field expressions can still participate in aggregate flows.
