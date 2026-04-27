# CA002 Cohort Month Acquisition Counts

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-datetime.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: cohort-analysis, acquisition, date-bucket

## Problem

Count how many customers entered each monthly first-order cohort.

## SQL

```sql
SELECT date_trunc('month', c.cohort_start) AS cohort_month,
       COUNT(*) AS customer_count
FROM first_order_cohorts AS c
GROUP BY date_trunc('month', c.cohort_start)
ORDER BY date_trunc('month', c.cohort_start) ASC;
```

## Selecto

```elixir
cohort_month = "date_trunc('month', selecto_root.cohort_start)"

query =
  Selecto.configure(first_order_cohort_domain(), :mock_connection, validate: false)
  |> Selecto.select([
    {:field, {:raw_sql, cohort_month}, "cohort_month"},
    {:count, "*"}
  ])
  |> Selecto.group_by([{:raw_sql, cohort_month}])
  |> Selecto.order_by({{:raw_sql, cohort_month}, :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

cohort_month = "date_trunc('month', selecto_root.cohort_start)"

Selecto.configure(first_order_cohort_domain(), :mock_connection, validate: false)
|> Selecto.select([as({:raw_sql, cohort_month}, "cohort_month"), count: "*"])
|> Selecto.group_by(raw_sql: cohort_month)
|> Selecto.order_by({{:raw_sql, cohort_month}, :asc})
```

## Selecto Yielded SQL

```sql
select date_trunc('month', selecto_root.cohort_start), count(*)
        from first_order_cohorts selecto_root
        group by date_trunc('month', selecto_root.cohort_start)

        order by date_trunc('month', selecto_root.cohort_start) asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `date_trunc('month'`
- includes keyword: `count`
- includes keyword: `group by`
- includes keyword: `order by`

## Notes

- This pattern assumes a view or subquery has already materialized one row per
  customer cohort.
