# Selecto Yielded SQL

Generated from `Selecto.to_sql/1` for every example in this repository.

## J001

### PostgreSQL

```sql
select selecto_root.order_number, customer.name
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( customer.id is not null ) and ( selecto_root.status = $1 ))
      
        order by selecto_root.order_number asc
```

**Params:** `["delivered"]`

### SQLite

```sql
select selecto_root.order_number, customer.name
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( customer.id is not null ) and ( selecto_root.status = ? ))
      
        order by selecto_root.order_number asc
```

**Params:** `["delivered"]`

## J002

### PostgreSQL

```sql
select selecto_root.name, COUNT(reviews.id)
        from products selecto_root left join reviews reviews on reviews.product_id = selecto_root.id
        group by selecto_root.name
      
        order by selecto_root.name asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.name, COUNT(reviews.id)
        from products selecto_root left join reviews reviews on reviews.product_id = selecto_root.id
        group by selecto_root.name
      
        order by selecto_root.name asc
```

**Params:** `[]`

## J003

### PostgreSQL

```sql
select selecto_root.name, selecto_root.tier, high_value_delivered.order_number, high_value_delivered.total
        from customers selecto_root inner join (
        select subq_root_orders_high_value_delivered.customer_id, subq_root_orders_high_value_delivered.order_number, subq_root_orders_high_value_delivered.total
        from orders subq_root_orders_high_value_delivered
        where (((( subq_root_orders_high_value_delivered.status = $1 ) and ( subq_root_orders_high_value_delivered.total > $2 ))))
      ) high_value_delivered on selecto_root.id = high_value_delivered.customer_id
```

**Params:** `["delivered", 1000]`

### SQLite

```sql
select selecto_root.name, selecto_root.tier, high_value_delivered.order_number, high_value_delivered.total
        from customers selecto_root inner join (
        select subq_root_orders_high_value_delivered.customer_id, subq_root_orders_high_value_delivered.order_number, subq_root_orders_high_value_delivered.total
        from orders subq_root_orders_high_value_delivered
        where (((( subq_root_orders_high_value_delivered.status = ? ) and ( subq_root_orders_high_value_delivered.total > ? ))))
      ) high_value_delivered on selecto_root.id = high_value_delivered.customer_id
```

**Params:** `["delivered", 1000]`

## J004

### PostgreSQL

```sql
select selecto_root.first_name, manager.first_name
        from employees selecto_root left join employees manager on manager.id = selecto_root.manager_id
        order by selecto_root.first_name asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.first_name, manager.first_name
        from employees selecto_root left join employees manager on manager.id = selecto_root.manager_id
        order by selecto_root.first_name asc
```

**Params:** `[]`

## J005

### PostgreSQL

```sql
select selecto_root.name
        from products selecto_root left join reviews reviews on reviews.product_id = selecto_root.id
        where (( reviews.id is null ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.name
        from products selecto_root left join reviews reviews on reviews.product_id = selecto_root.id
        where (( reviews.id is null ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

## J006

### PostgreSQL

```sql
select selecto_root.order_number, "customer:tier_premium".name, "customer:tier_standard".name
        from orders selecto_root left join customers "customer:tier_premium" on "customer:tier_premium".id = selecto_root.customer_id and "customer:tier_premium".tier = $1 left join customers "customer:tier_standard" on "customer:tier_standard".id = selecto_root.customer_id and "customer:tier_standard".tier = $2
```

**Params:** `["premium", "standard"]`

### SQLite

```sql
select selecto_root.order_number, "customer:tier_premium".name, "customer:tier_standard".name
        from orders selecto_root left join customers "customer:tier_premium" on "customer:tier_premium".id = selecto_root.customer_id and "customer:tier_premium".tier = ? left join customers "customer:tier_standard" on "customer:tier_standard".id = selecto_root.customer_id and "customer:tier_standard".tier = ?
```

**Params:** `["premium", "standard"]`

## J007

### PostgreSQL

```sql
select selecto_root.name, delivered_stats.count
        from products selecto_root LEFT JOIN LATERAL (
        select count(*)
        from orders subq_root_orders
        where (( subq_root_orders.status = $1 ))
      ) AS delivered_stats ON true
```

**Params:** `["delivered"]`

### SQLite

_Unavailable:_ `Adapter does not support lateral/apply joins`

## J008

### PostgreSQL

```sql
select selecto_root.name, product_tag
        from products selecto_root CROSS JOIN LATERAL UNNEST("selecto_root"."tags") AS product_tag
        where (( selecto_root.active = $1 ))
```

**Params:** `[true]`

### SQLite

```sql
select selecto_root.name, product_tag
        from products selecto_root CROSS JOIN LATERAL UNNEST("selecto_root"."tags") AS product_tag
        where (( selecto_root.active = ? ))
```

**Params:** `[true]`

## J009

### PostgreSQL

```sql
select selecto_root.order_number, "customer:alias_a".name, "customer:alias_b".tier
        from orders selecto_root left join customers "customer:alias_a" on "customer:alias_a".id = selecto_root.customer_id left join customers "customer:alias_b" on "customer:alias_b".id = selecto_root.customer_id
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.order_number, "customer:alias_a".name, "customer:alias_b".tier
        from orders selecto_root left join customers "customer:alias_a" on "customer:alias_a".id = selecto_root.customer_id left join customers "customer:alias_b" on "customer:alias_b".id = selecto_root.customer_id
```

**Params:** `[]`

## J010

### PostgreSQL

```sql
select customer.name, count(*)
        from orders selecto_root LEFT JOIN customers customer ON selecto_root.customer_id = customer.id
        group by customer.name
      
        order by customer.name asc
```

**Params:** `[]`

### SQLite

```sql
select customer.name, count(*)
        from orders selecto_root LEFT JOIN customers customer ON selecto_root.customer_id = customer.id
        group by customer.name
      
        order by customer.name asc
```

**Params:** `[]`

## J011

### PostgreSQL

```sql
select selecto_root.order_number, gold_customers.name, selecto_root.total
        from orders selecto_root inner join (
        select subq_root_customers_gold_customers.id, subq_root_customers_gold_customers.name, subq_root_customers_gold_customers.tier
        from customers subq_root_customers_gold_customers
        where (( subq_root_customers_gold_customers.tier = $1 ))
      ) gold_customers on selecto_root.customer_id = gold_customers.id
        order by selecto_root.order_number asc
```

**Params:** `["gold"]`

### SQLite

```sql
select selecto_root.order_number, gold_customers.name, selecto_root.total
        from orders selecto_root inner join (
        select subq_root_customers_gold_customers.id, subq_root_customers_gold_customers.name, subq_root_customers_gold_customers.tier
        from customers subq_root_customers_gold_customers
        where (( subq_root_customers_gold_customers.tier = ? ))
      ) gold_customers on selecto_root.customer_id = gold_customers.id
        order by selecto_root.order_number asc
```

**Params:** `["gold"]`

## J012

### PostgreSQL

```sql
select selecto_root.name, selecto_root.tier, processing_orders.order_number
        from customers selecto_root left join (
        select subq_root_orders_processing_orders.customer_id, subq_root_orders_processing_orders.order_number
        from orders subq_root_orders_processing_orders
        where (( subq_root_orders_processing_orders.status = $1 ))
      ) processing_orders on selecto_root.id = processing_orders.customer_id
        order by selecto_root.name asc
```

**Params:** `["processing"]`

### SQLite

```sql
select selecto_root.name, selecto_root.tier, processing_orders.order_number
        from customers selecto_root left join (
        select subq_root_orders_processing_orders.customer_id, subq_root_orders_processing_orders.order_number
        from orders subq_root_orders_processing_orders
        where (( subq_root_orders_processing_orders.status = ? ))
      ) processing_orders on selecto_root.id = processing_orders.customer_id
        order by selecto_root.name asc
```

**Params:** `["processing"]`

## A001

### PostgreSQL

```sql
select selecto_root.status, count(*)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.status, count(*)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

## A002

### PostgreSQL

```sql
select selecto_root.customer_id, SUM(selecto_root.total)
        from orders selecto_root
        where (( selecto_root.status = $1 ))
      
        group by selecto_root.customer_id
      
        order by selecto_root.customer_id asc
```

**Params:** `["delivered"]`

### SQLite

```sql
select selecto_root.customer_id, SUM(selecto_root.total)
        from orders selecto_root
        where (( selecto_root.status = ? ))
      
        group by selecto_root.customer_id
      
        order by selecto_root.customer_id asc
```

**Params:** `["delivered"]`

## A003

### PostgreSQL

```sql
select selecto_root.status, AVG(selecto_root.total)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.status, AVG(selecto_root.total)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

## A004

### PostgreSQL

```sql
select customer.name, count(*)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        group by customer.name
      
        order by customer.name asc
```

**Params:** `[]`

### SQLite

```sql
select customer.name, count(*)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        group by customer.name
      
        order by customer.name asc
```

**Params:** `[]`

## A005

### PostgreSQL

```sql
select customer.tier, SUM(selecto_root.total)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        group by customer.tier
      
        order by customer.tier asc
```

**Params:** `[]`

### SQLite

```sql
select customer.tier, SUM(selecto_root.total)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        group by customer.tier
      
        order by customer.tier asc
```

**Params:** `[]`

## A006

### PostgreSQL

```sql
select customer.tier, count(*)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( selecto_root.status = $1 ))
      
        group by customer.tier
      
        order by customer.tier asc
```

**Params:** `["delivered"]`

### SQLite

```sql
select customer.tier, count(*)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( selecto_root.status = ? ))
      
        group by customer.tier
      
        order by customer.tier asc
```

**Params:** `["delivered"]`

## A007

### PostgreSQL

```sql
select selecto_root.status, SUM(selecto_root.total), count(*)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.status, SUM(selecto_root.total), count(*)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

## A008

### PostgreSQL

```sql
select customer.tier, AVG(selecto_root.total)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( selecto_root.status = $1 ))
      
        group by customer.tier
      
        order by customer.tier asc
```

**Params:** `["delivered"]`

### SQLite

```sql
select customer.tier, AVG(selecto_root.total)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( selecto_root.status = ? ))
      
        group by customer.tier
      
        order by customer.tier asc
```

**Params:** `["delivered"]`

## A009

### PostgreSQL

```sql
select selecto_root.status, MIN(selecto_root.total), MAX(selecto_root.total)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.status, MIN(selecto_root.total), MAX(selecto_root.total)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

## A010

### PostgreSQL

```sql
select selecto_root.name, COUNT(reviews.id), AVG(reviews.rating)
        from products selecto_root left join reviews reviews on reviews.product_id = selecto_root.id
        group by selecto_root.name
      
        order by selecto_root.name asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.name, COUNT(reviews.id), AVG(reviews.rating)
        from products selecto_root left join reviews reviews on reviews.product_id = selecto_root.id
        group by selecto_root.name
      
        order by selecto_root.name asc
```

**Params:** `[]`

## W001

### PostgreSQL

```sql
select selecto_root.first_name, selecto_root.department, selecto_root.salary, ROW_NUMBER() OVER (PARTITION BY selecto_root.department ORDER BY selecto_root.salary DESC) AS "department_salary_rank"
        from employees selecto_root
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.first_name, selecto_root.department, selecto_root.salary, ROW_NUMBER() OVER (PARTITION BY selecto_root.department ORDER BY selecto_root.salary DESC) AS "department_salary_rank"
        from employees selecto_root
```

**Params:** `[]`

## W002

### PostgreSQL

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, SUM(selecto_root.total) OVER (PARTITION BY selecto_root.customer_id ORDER BY selecto_root.id ASC) AS "running_total"
        from orders selecto_root
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, SUM(selecto_root.total) OVER (PARTITION BY selecto_root.customer_id ORDER BY selecto_root.id ASC) AS "running_total"
        from orders selecto_root
```

**Params:** `[]`

## W003

### PostgreSQL

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, LAG(selecto_root.total) OVER (PARTITION BY selecto_root.customer_id ORDER BY selecto_root.id ASC) AS "prev_total"
        from orders selecto_root
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, LAG(selecto_root.total) OVER (PARTITION BY selecto_root.customer_id ORDER BY selecto_root.id ASC) AS "prev_total"
        from orders selecto_root
```

**Params:** `[]`

## W004

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.total, DENSE_RANK() OVER (ORDER BY selecto_root.total DESC) AS "total_rank"
        from orders selecto_root
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.total, DENSE_RANK() OVER (ORDER BY selecto_root.total DESC) AS "total_rank"
        from orders selecto_root
```

**Params:** `[]`

## W005

### PostgreSQL

```sql
select selecto_root.id, selecto_root.total, AVG(selecto_root.total) OVER (ORDER BY selecto_root.id ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "moving_avg_total"
        from orders selecto_root
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.total, AVG(selecto_root.total) OVER (ORDER BY selecto_root.id ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "moving_avg_total"
        from orders selecto_root
```

**Params:** `[]`

## W006

### PostgreSQL

```sql
select selecto_root.first_name, selecto_root.department, selecto_root.salary, RANK() OVER (PARTITION BY selecto_root.department ORDER BY selecto_root.salary DESC) AS "department_rank"
        from employees selecto_root
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.first_name, selecto_root.department, selecto_root.salary, RANK() OVER (PARTITION BY selecto_root.department ORDER BY selecto_root.salary DESC) AS "department_rank"
        from employees selecto_root
```

**Params:** `[]`

## W007

### PostgreSQL

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, LEAD(selecto_root.total) OVER (PARTITION BY selecto_root.customer_id ORDER BY selecto_root.id ASC) AS "next_total"
        from orders selecto_root
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, LEAD(selecto_root.total) OVER (PARTITION BY selecto_root.customer_id ORDER BY selecto_root.id ASC) AS "next_total"
        from orders selecto_root
```

**Params:** `[]`

## W008

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total, MAX(selecto_root.total) OVER (PARTITION BY selecto_root.status) AS "status_max_total"
        from orders selecto_root
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total, MAX(selecto_root.total) OVER (PARTITION BY selecto_root.status) AS "status_max_total"
        from orders selecto_root
```

**Params:** `[]`

## W009

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.total, PERCENT_RANK() OVER (ORDER BY selecto_root.total DESC) AS "total_percent_rank"
        from orders selecto_root
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.total, PERCENT_RANK() OVER (ORDER BY selecto_root.total DESC) AS "total_percent_rank"
        from orders selecto_root
```

**Params:** `[]`

## W010

### PostgreSQL

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, COUNT(*) OVER (PARTITION BY selecto_root.customer_id) AS "customer_order_count"
        from orders selecto_root
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, COUNT(*) OVER (PARTITION BY selecto_root.customer_id) AS "customer_order_count"
        from orders selecto_root
```

**Params:** `[]`

## S001

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (
        select subq_root_customers.id
        from customers subq_root_customers
        where (( subq_root_customers.tier = $1 ))
      ) ))
      
        order by selecto_root.total desc
```

**Params:** `["gold"]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (
        select subq_root_customers.id
        from customers subq_root_customers
        where (( subq_root_customers.tier = ? ))
      ) ))
      
        order by selecto_root.total desc
```

**Params:** `["gold"]`

## S002

### PostgreSQL

```sql
select selecto_root.name, delivered_orders.order_number, delivered_orders.total
        from customers selecto_root left join (
        select subq_root_orders_delivered_orders.customer_id, subq_root_orders_delivered_orders.order_number, subq_root_orders_delivered_orders.total
        from orders subq_root_orders_delivered_orders
        where (( subq_root_orders_delivered_orders.status = $1 ))
      ) delivered_orders on selecto_root.id = delivered_orders.customer_id
        order by selecto_root.name asc
```

**Params:** `["delivered"]`

### SQLite

```sql
select selecto_root.name, delivered_orders.order_number, delivered_orders.total
        from customers selecto_root left join (
        select subq_root_orders_delivered_orders.customer_id, subq_root_orders_delivered_orders.order_number, subq_root_orders_delivered_orders.total
        from orders subq_root_orders_delivered_orders
        where (( subq_root_orders_delivered_orders.status = ? ))
      ) delivered_orders on selecto_root.id = delivered_orders.customer_id
        order by selecto_root.name asc
```

**Params:** `["delivered"]`

## S003

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( exists (SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = 'gold') ))
      
        order by selecto_root.total desc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( exists (SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = 'gold') ))
      
        order by selecto_root.total desc
```

**Params:** `[]`

## S004

### PostgreSQL

```sql
select selecto_root.name
        from products selecto_root left join (
        select subq_root_reviews_reviewed_products.product_id
        from reviews subq_root_reviews_reviewed_products
        group by subq_root_reviews_reviewed_products.product_id
      ) reviewed_products on selecto_root.id = reviewed_products.product_id
        where (( reviewed_products.product_id is null ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.name
        from products selecto_root left join (
        select subq_root_reviews_reviewed_products.product_id
        from reviews subq_root_reviews_reviewed_products
        group by subq_root_reviews_reviewed_products.product_id
      ) reviewed_products on selecto_root.id = reviewed_products.product_id
        where (( reviewed_products.product_id is null ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

## S005

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (
        select subq_root_customers.id
        from customers subq_root_customers
        where (( subq_root_customers.tier = $1 ))
      ) ))
      
        order by selecto_root.total desc
```

**Params:** `["silver"]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (
        select subq_root_customers.id
        from customers subq_root_customers
        where (( subq_root_customers.tier = ? ))
      ) ))
      
        order by selecto_root.total desc
```

**Params:** `["silver"]`

## S006

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( exists (SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = $1) ))
      
        order by selecto_root.total desc
```

**Params:** `["gold"]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( exists (SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = ?) ))
      
        order by selecto_root.total desc
```

**Params:** `["gold"]`

## S007

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (
        select subq_root_customers.id
        from customers subq_root_customers
        where (( subq_root_customers.tier = $1 ))
      ) ) and ( selecto_root.status = $2 ))
      
        order by selecto_root.total desc
```

**Params:** `["gold", "delivered"]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (
        select subq_root_customers.id
        from customers subq_root_customers
        where (( subq_root_customers.tier = ? ))
      ) ) and ( selecto_root.status = ? ))
      
        order by selecto_root.total desc
```

**Params:** `["gold", "delivered"]`

## S008

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.total > all (
        select subq_root_orders.total
        from orders subq_root_orders
        where (( subq_root_orders.status = $1 ))
      ) ))
      
        order by selecto_root.total desc
```

**Params:** `["returned"]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.total > all (
        select subq_root_orders.total
        from orders subq_root_orders
        where (( subq_root_orders.status = ? ))
      ) ))
      
        order by selecto_root.total desc
```

**Params:** `["returned"]`

## S009

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.total < any (
        select subq_root_orders.total
        from orders subq_root_orders
        where (( subq_root_orders.status = $1 ))
      ) ))
      
        order by selecto_root.total asc
```

**Params:** `["delivered"]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.total < any (
        select subq_root_orders.total
        from orders subq_root_orders
        where (( subq_root_orders.status = ? ))
      ) ))
      
        order by selecto_root.total asc
```

**Params:** `["delivered"]`

## S010

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.status = $1 ) and (not (  exists (SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = $2)  ) ))
      
        order by selecto_root.total desc
```

**Params:** `["processing", "suspended"]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.status = ? ) and (not (  exists (SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = ?)  ) ))
      
        order by selecto_root.total desc
```

**Params:** `["processing", "suspended"]`

## SO001

### PostgreSQL

```sql
(
        select selecto_root.name, selecto_root.tier
        from customers selecto_root)
UNION
(
        select selecto_root.name, selecto_root.tier
        from vendors selecto_root)
```

**Params:** `[]`

### SQLite

```sql
(
        select selecto_root.name, selecto_root.tier
        from customers selecto_root)
UNION
(
        select selecto_root.name, selecto_root.tier
        from vendors selecto_root)
```

**Params:** `[]`

## SO002

### PostgreSQL

```sql
(
        select selecto_root.order_number, selecto_root.total
        from orders selecto_root)
UNION ALL
(
        select selecto_root.order_number, selecto_root.total
        from archived_orders selecto_root)
```

**Params:** `[]`

### SQLite

```sql
(
        select selecto_root.order_number, selecto_root.total
        from orders selecto_root)
UNION ALL
(
        select selecto_root.order_number, selecto_root.total
        from archived_orders selecto_root)
```

**Params:** `[]`

## SO003

### PostgreSQL

```sql
(
        select selecto_root.id, selecto_root.name
        from premium_customers selecto_root)
INTERSECT
(
        select selecto_root.id, selecto_root.name
        from active_customers selecto_root)
```

**Params:** `[]`

### SQLite

```sql
(
        select selecto_root.id, selecto_root.name
        from premium_customers selecto_root)
INTERSECT
(
        select selecto_root.id, selecto_root.name
        from active_customers selecto_root)
```

**Params:** `[]`

## SO004

### PostgreSQL

```sql
(
        select selecto_root.id, selecto_root.name
        from customers selecto_root)
EXCEPT
(
        select selecto_root.id, selecto_root.name
        from blocked_customers selecto_root)
```

**Params:** `[]`

### SQLite

```sql
(
        select selecto_root.id, selecto_root.name
        from customers selecto_root)
EXCEPT
(
        select selecto_root.id, selecto_root.name
        from blocked_customers selecto_root)
```

**Params:** `[]`

## SO005

### PostgreSQL

```sql
((
        select selecto_root.id, selecto_root.name
        from premium_customers selecto_root)
UNION
(
        select selecto_root.id, selecto_root.name
        from active_customers selecto_root))
INTERSECT
(
        select selecto_root.id, selecto_root.name
        from customers selecto_root)
```

**Params:** `[]`

### SQLite

```sql
((
        select selecto_root.id, selecto_root.name
        from premium_customers selecto_root)
UNION
(
        select selecto_root.id, selecto_root.name
        from active_customers selecto_root))
INTERSECT
(
        select selecto_root.id, selecto_root.name
        from customers selecto_root)
```

**Params:** `[]`

## SO006

### PostgreSQL

```sql
(
        select selecto_root.id, selecto_root.name
        from premium_customers selecto_root)
INTERSECT ALL
(
        select selecto_root.id, selecto_root.name
        from active_customers selecto_root)
```

**Params:** `[]`

### SQLite

```sql
(
        select selecto_root.id, selecto_root.name
        from premium_customers selecto_root)
INTERSECT ALL
(
        select selecto_root.id, selecto_root.name
        from active_customers selecto_root)
```

**Params:** `[]`

## SO007

### PostgreSQL

```sql
(
        select selecto_root.id, selecto_root.name
        from customers selecto_root)
EXCEPT ALL
(
        select selecto_root.id, selecto_root.name
        from blocked_customers selecto_root)
```

**Params:** `[]`

### SQLite

```sql
(
        select selecto_root.id, selecto_root.name
        from customers selecto_root)
EXCEPT ALL
(
        select selecto_root.id, selecto_root.name
        from blocked_customers selecto_root)
```

**Params:** `[]`

## SO008

### PostgreSQL

```sql
(
        select selecto_root.name, selecto_root.tier
        from customers selecto_root)
UNION
(
        select selecto_root.company_name, selecto_root.segment
        from vendor_contacts selecto_root)
```

**Params:** `[]`

### SQLite

```sql
(
        select selecto_root.name, selecto_root.tier
        from customers selecto_root)
UNION
(
        select selecto_root.company_name, selecto_root.segment
        from vendor_contacts selecto_root)
```

**Params:** `[]`

## F001

### PostgreSQL

```sql
select selecto_root.order_number, customer.name, selecto_root.status
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( customer.id is not null ) and ( NOT (selecto_root.status = ANY($1)) ))
      
        order by selecto_root.order_number asc
```

**Params:** `[["cancelled", "returned"]]`

### SQLite

```sql
select selecto_root.order_number, customer.name, selecto_root.status
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( customer.id is not null ) and ( selecto_root.status NOT IN (?) ))
      
        order by selecto_root.order_number asc
```

**Params:** `[["cancelled", "returned"]]`

## F002

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (((((( selecto_root.status = $1 ) or ( selecto_root.status = $2 ))) and ( selecto_root.total > $3 ))))
      
        order by selecto_root.total desc
```

**Params:** `["processing", "shipped", 100]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (((((( selecto_root.status = ? ) or ( selecto_root.status = ? ))) and ( selecto_root.total > ? ))))
      
        order by selecto_root.total desc
```

**Params:** `["processing", "shipped", 100]`

## F003

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.total between $1 and $2 ) and ( selecto_root.status = ANY($3) ))
      
        order by selecto_root.order_number asc
```

**Params:** `[100, 500, ["processing", "shipped", "delivered"]]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.total between ? and ? ) and ( selecto_root.status IN (?) ))
      
        order by selecto_root.order_number asc
```

**Params:** `[100, 500, ["processing", "shipped", "delivered"]]`

## F004

### PostgreSQL

```sql
select selecto_root.name, selecto_root.sku
        from products selecto_root
        where (( selecto_root.name @@ websearch_to_tsquery($1) ))
      
        order by selecto_root.name asc
```

**Params:** `["wireless charger"]`

### SQLite

_Unavailable:_ `SQLite text search requires an FTS5-configured field`

## F005

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where ((not (  selecto_root.status = $1  ) ) and ( selecto_root.total > $2 ))
      
        order by selecto_root.total desc
```

**Params:** `["cancelled", 50]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where ((not (  selecto_root.status = ?  ) ) and ( selecto_root.total > ? ))
      
        order by selecto_root.total desc
```

**Params:** `["cancelled", 50]`

## F006

### PostgreSQL

```sql
select selecto_root.name, selecto_root.tags
        from products selecto_root
        where (( selecto_root.tags @> $1 ))
      
        order by selecto_root.name asc
```

**Params:** `[["featured"]]`

### SQLite

```sql
select selecto_root.name, selecto_root.tags
        from products selecto_root
        where (( selecto_root.tags @> ? ))
      
        order by selecto_root.name asc
```

**Params:** `[["featured"]]`

## F007

### PostgreSQL

```sql
select selecto_root.name, "selecto_root"."metadata"#>>'{warehouse,zone}'
        from products selecto_root
        where (( "selecto_root"."metadata"->'warehouse' ? 'zone' ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.name, json_extract("selecto_root"."metadata", '$.warehouse.zone')
        from products selecto_root
        where (( json_type("selecto_root"."metadata", '$.warehouse.zone') IS NOT NULL ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

## F008

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (
        select subq_root_customers.id
        from customers subq_root_customers
        where (( subq_root_customers.tier = $1 ))
      ) ) and ( selecto_root.status = $2 ))
      
        order by selecto_root.total desc
```

**Params:** `["platinum", "processing"]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (
        select subq_root_customers.id
        from customers subq_root_customers
        where (( subq_root_customers.tier = ? ))
      ) ) and ( selecto_root.status = ? ))
      
        order by selecto_root.total desc
```

**Params:** `["platinum", "processing"]`

## P001

### PostgreSQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        order by selecto_root.id asc
      
        limit 25
        offset 50
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        order by selecto_root.id asc
      
        limit 25
        offset 50
```

**Params:** `[]`

## P002

### PostgreSQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        where (( selecto_root.id > $1 ))
      
        order by selecto_root.id asc
      
        limit 25
```

**Params:** `[1000]`

### SQLite

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        where (( selecto_root.id > ? ))
      
        order by selecto_root.id asc
      
        limit 25
```

**Params:** `[1000]`

## P003

### PostgreSQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        where (( selecto_root.id < $1 ))
      
        order by selecto_root.id desc
      
        limit 20
```

**Params:** `[5000]`

### SQLite

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        where (( selecto_root.id < ? ))
      
        order by selecto_root.id desc
      
        limit 20
```

**Params:** `[5000]`

## P004

### PostgreSQL

```sql
select selecto_root.order_number, customer.name, selecto_root.total
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        order by customer.name asc, selecto_root.order_number asc
      
        limit 15
        offset 30
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.order_number, customer.name, selecto_root.total
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        order by customer.name asc, selecto_root.order_number asc
      
        limit 15
        offset 30
```

**Params:** `[]`

## P005

### PostgreSQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from orders selecto_root
        where (( selecto_root.inserted_at > $1 ))
      
        order by selecto_root.inserted_at asc, selecto_root.id asc
      
        limit 25
```

**Params:** `[~N[2024-01-15 00:00:00]]`

### SQLite

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from orders selecto_root
        where (( selecto_root.inserted_at > ? ))
      
        order by selecto_root.inserted_at asc, selecto_root.id asc
      
        limit 25
```

**Params:** `[~N[2024-01-15 00:00:00]]`

## P006

### PostgreSQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        order by selecto_root.total desc, selecto_root.id desc
      
        limit 20
        offset 40
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        order by selecto_root.total desc, selecto_root.id desc
      
        limit 20
        offset 40
```

**Params:** `[]`

## P007

### PostgreSQL

```sql
(
        select selecto_root.order_number, selecto_root.total
        from orders selecto_root)
UNION ALL
(
        select selecto_root.order_number, selecto_root.total
        from archived_orders selecto_root)
ORDER BY selecto_root.order_number asc
limit 20
offset 20
```

**Params:** `[]`

### SQLite

```sql
(
        select selecto_root.order_number, selecto_root.total
        from orders selecto_root)
UNION ALL
(
        select selecto_root.order_number, selecto_root.total
        from archived_orders selecto_root)
ORDER BY selecto_root.order_number asc
limit 20
offset 20
```

**Params:** `[]`

## P008

### PostgreSQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        where (((( selecto_root.total < $1 ) or ((( selecto_root.total = $2 ) and ( selecto_root.id < $3 ))))))
      
        order by selecto_root.total desc, selecto_root.id desc
      
        limit 20
```

**Params:** `[1000, 1000, 500]`

### SQLite

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        where (((( selecto_root.total < ? ) or ((( selecto_root.total = ? ) and ( selecto_root.id < ? ))))))
      
        order by selecto_root.total desc, selecto_root.id desc
      
        limit 20
```

**Params:** `[1000, 1000, 500]`

## JA001

### PostgreSQL

```sql
select selecto_root.name, selecto_root.sku, metadata ->> 'price_band' AS "price_band"
        from products selecto_root
        where (( "metadata" @> '{"price_band":"premium"}'::jsonb ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.name, selecto_root.sku, json_extract("selecto_root"."metadata", '$.price_band') AS "price_band"
        from products selecto_root
        where (( json_extract("selecto_root"."metadata", '$.price_band') = 'premium' ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

## JA002

### PostgreSQL

```sql
select selecto_root.name, "selecto_root"."metadata"#>>'{warehouse,zone}'
        from products selecto_root
        where (( "selecto_root"."metadata"->'warehouse' ? 'zone' ) and ( "selecto_root"."metadata"#>>'{warehouse,zone}' = $1 ))
      
        order by selecto_root.name asc
```

**Params:** `["A1"]`

### SQLite

```sql
select selecto_root.name, json_extract("selecto_root"."metadata", '$.warehouse.zone')
        from products selecto_root
        where (( json_type("selecto_root"."metadata", '$.warehouse.zone') IS NOT NULL ) and ( json_extract("selecto_root"."metadata", '$.warehouse.zone') = ? ))
      
        order by selecto_root.name asc
```

**Params:** `["A1"]`

## JA003

### PostgreSQL

```sql
select selecto_root.name, selecto_root.tags
        from products selecto_root
        where (( selecto_root.tags && $1 ) and ( selecto_root.active = $2 ))
      
        order by selecto_root.name asc
```

**Params:** `[["featured", "clearance"], true]`

### SQLite

```sql
select selecto_root.name, selecto_root.tags
        from products selecto_root
        where (( selecto_root.tags && ? ) and ( selecto_root.active = ? ))
      
        order by selecto_root.name asc
```

**Params:** `[["featured", "clearance"], true]`

## JA004

### PostgreSQL

```sql
select selecto_root.name, metadata -> 'stock' ->> 'quantity' AS "stock_quantity"
        from products selecto_root
        where (( "metadata"->'stock' ? 'quantity' ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.name, json_extract("selecto_root"."metadata", '$.stock.quantity') AS "stock_quantity"
        from products selecto_root
        where (( json_type("selecto_root"."metadata", '$.stock.quantity') IS NOT NULL ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

## JA005

### PostgreSQL

```sql
select selecto_root.name, selecto_root.sku, metadata -> 'warehouse' ->> 'zone' AS "warehouse_zone"
        from products selecto_root
        order by metadata -> 'warehouse' ->> 'zone' asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.name, selecto_root.sku, json_extract("selecto_root"."metadata", '$.warehouse.zone') AS "warehouse_zone"
        from products selecto_root
        order by json_extract("selecto_root"."metadata", '$.warehouse.zone') asc
```

**Params:** `[]`

## JA006

### PostgreSQL

```sql
select selecto_root.name, selecto_root.tags
        from products selecto_root
        where (( selecto_root.tags @> $1 ))
      
        order by selecto_root.name asc
```

**Params:** `[["featured", "clearance"]]`

### SQLite

```sql
select selecto_root.name, selecto_root.tags
        from products selecto_root
        where (( selecto_root.tags @> ? ))
      
        order by selecto_root.name asc
```

**Params:** `[["featured", "clearance"]]`

## JA007

### PostgreSQL

```sql
select selecto_root.name, selecto_root.sku, "selecto_root"."metadata"#>>'{warehouse,zone}'
        from products selecto_root
        where (( "selecto_root"."metadata"#>>'{warehouse,zone}' = $1 ) and ( selecto_root.active = $2 ))
      
        order by selecto_root.name asc
```

**Params:** `["A1", true]`

### SQLite

```sql
select selecto_root.name, selecto_root.sku, json_extract("selecto_root"."metadata", '$.warehouse.zone')
        from products selecto_root
        where (( json_extract("selecto_root"."metadata", '$.warehouse.zone') = ? ) and ( selecto_root.active = ? ))
      
        order by selecto_root.name asc
```

**Params:** `["A1", true]`

## JA008

### PostgreSQL

```sql
select selecto_root.name, selecto_root.sku, metadata -> 'warehouse' ->> 'zone' AS "warehouse_zone", metadata -> 'stock' ->> 'quantity' AS "stock_quantity"
        from products selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.name, selecto_root.sku, json_extract("selecto_root"."metadata", '$.warehouse.zone') AS "warehouse_zone", json_extract("selecto_root"."metadata", '$.stock.quantity') AS "stock_quantity"
        from products selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

## Q001

### PostgreSQL

```sql
select selecto_root.name, selecto_root.email, (SELECT json_agg(json_build_object('product_name', sub_orders."product_name", 'quantity', sub_orders."quantity")) FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "order_items"
        from attendees selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.name, selecto_root.email, (SELECT json_agg(json_build_object('product_name', sub_orders."product_name", 'quantity', sub_orders."quantity")) FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "order_items"
        from attendees selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

## Q002

### PostgreSQL

```sql
select t.product_name, t.quantity
        from orders t
        where EXISTS (SELECT 1 FROM events sub_s INNER JOIN attendees j_attendees ON sub_s.event_id = j_attendees.event_id INNER JOIN orders j_orders ON j_attendees.attendee_id = j_orders.attendee_id WHERE j_orders.order_id = t.order_id AND sub_s.event_id = $1)
```

**Params:** `[1000]`

### SQLite

```sql
select t.product_name, t.quantity
        from orders t
        where EXISTS (SELECT 1 FROM events sub_s INNER JOIN attendees j_attendees ON sub_s.event_id = j_attendees.event_id INNER JOIN orders j_orders ON j_attendees.attendee_id = j_orders.attendee_id WHERE j_orders.order_id = t.order_id AND sub_s.event_id = ?)
```

**Params:** `[1000]`

## Q003

### PostgreSQL

```sql
select t.product_name, t.quantity
        from orders t
        where t.order_id IN (SELECT DISTINCT j2.order_id FROM events s JOIN attendees j1 ON s.event_id = j1.event_id JOIN orders j2 ON j1.attendee_id = j2.attendee_id WHERE s.event_id = $1)
```

**Params:** `[2000]`

### SQLite

```sql
select t.product_name, t.quantity
        from orders t
        where t.order_id IN (SELECT DISTINCT j2.order_id FROM events s JOIN attendees j1 ON s.event_id = j1.event_id JOIN orders j2 ON j1.attendee_id = j2.attendee_id WHERE s.event_id = ?)
```

**Params:** `[2000]`

## Q004

### PostgreSQL

```sql
select selecto_root.name, selecto_root.email, (SELECT json_agg(sub_orders."product_name") FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "products", (SELECT array_agg(sub_orders."quantity") FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "quantities"
        from attendees selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.name, selecto_root.email, (SELECT json_agg(sub_orders."product_name") FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "products", (SELECT array_agg(sub_orders."quantity") FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "quantities"
        from attendees selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

## Q005

### PostgreSQL

```sql
select selecto_root.name, selecto_root.email, (SELECT count(*) FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "order_count"
        from attendees selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.name, selecto_root.email, (SELECT count(*) FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "order_count"
        from attendees selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

## Q006

### PostgreSQL

```sql
select selecto_root.name, selecto_root.tier, processing_orders_member.order_number
        from customers selecto_root left join (
        select subq_root_orders_processing_orders_member.customer_id, subq_root_orders_processing_orders_member.order_number, subq_root_orders_processing_orders_member.total
        from orders subq_root_orders_processing_orders_member
        where (( subq_root_orders_processing_orders_member.status = $1 ))
      ) processing_orders_member on selecto_root.id = processing_orders_member.customer_id
        order by selecto_root.name asc
```

**Params:** `["processing"]`

### SQLite

```sql
select selecto_root.name, selecto_root.tier, processing_orders_member.order_number
        from customers selecto_root left join (
        select subq_root_orders_processing_orders_member.customer_id, subq_root_orders_processing_orders_member.order_number, subq_root_orders_processing_orders_member.total
        from orders subq_root_orders_processing_orders_member
        where (( subq_root_orders_processing_orders_member.status = ? ))
      ) processing_orders_member on selecto_root.id = processing_orders_member.customer_id
        order by selecto_root.name asc
```

**Params:** `["processing"]`

## Q007

### PostgreSQL

```sql
WITH delivered_totals (id, total) AS (
    
        select selecto_root.id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.status = $1 ))
      
)

        select selecto_root.order_number, customer.name, delivered_totals.total
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id left join delivered_totals delivered_totals on delivered_totals.id = selecto_root.id
        order by selecto_root.order_number asc
```

**Params:** `["delivered"]`

### SQLite

```sql
WITH delivered_totals (id, total) AS (
    
        select selecto_root.id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.status = ? ))
      
)

        select selecto_root.order_number, customer.name, delivered_totals.total
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id left join delivered_totals delivered_totals on delivered_totals.id = selecto_root.id
        order by selecto_root.order_number asc
```

**Params:** `["delivered"]`

## Q008

### PostgreSQL

```sql
((
        select selecto_root.order_number, selecto_root.total
        from orders selecto_root)
UNION ALL
(
        select selecto_root.order_number, selecto_root.total
        from archived_orders selecto_root))
EXCEPT
(
        select selecto_root.order_number, selecto_root.total
        from archived_orders selecto_root)
```

**Params:** `[]`

### SQLite

```sql
((
        select selecto_root.order_number, selecto_root.total
        from orders selecto_root)
UNION ALL
(
        select selecto_root.order_number, selecto_root.total
        from archived_orders selecto_root))
EXCEPT
(
        select selecto_root.order_number, selecto_root.total
        from archived_orders selecto_root)
```

**Params:** `[]`

## T001

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from orders selecto_root
        where (( (selecto_root.inserted_at >= $1 and selecto_root.inserted_at < $2) ))
      
        order by selecto_root.inserted_at asc
```

**Params:** `[~N[2024-01-01 00:00:00], ~N[2024-02-01 00:00:00]]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from orders selecto_root
        where (( (selecto_root.inserted_at >= ? and selecto_root.inserted_at < ?) ))
      
        order by selecto_root.inserted_at asc
```

**Params:** `[~N[2024-01-01 00:00:00], ~N[2024-02-01 00:00:00]]`

## T002

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total, SUM(selecto_root.total) OVER (ORDER BY selecto_root.inserted_at ASC) AS "running_total"
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total, SUM(selecto_root.total) OVER (ORDER BY selecto_root.inserted_at ASC) AS "running_total"
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

## T003

### PostgreSQL

```sql
select selecto_root.order_number, date_trunc('day', selecto_root.inserted_at), selecto_root.total
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.order_number, date_trunc('day', selecto_root.inserted_at), selecto_root.total
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

## T004

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total, AVG(selecto_root.total) OVER (ORDER BY selecto_root.inserted_at ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS "trailing_avg_total"
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total, AVG(selecto_root.total) OVER (ORDER BY selecto_root.inserted_at ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS "trailing_avg_total"
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

## T005

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total, LAG(selecto_root.total) OVER (ORDER BY selecto_root.inserted_at ASC) AS "previous_total"
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total, LAG(selecto_root.total) OVER (ORDER BY selecto_root.inserted_at ASC) AS "previous_total"
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

## T006

### PostgreSQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.inserted_at, selecto_root.total, SUM(selecto_root.total) OVER (PARTITION BY selecto_root.status ORDER BY selecto_root.inserted_at ASC) AS "status_running_total"
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.inserted_at, selecto_root.total, SUM(selecto_root.total) OVER (PARTITION BY selecto_root.status ORDER BY selecto_root.inserted_at ASC) AS "status_running_total"
        from orders selecto_root
        order by selecto_root.inserted_at asc
```

**Params:** `[]`

## T007

### PostgreSQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from orders selecto_root
        where (((( selecto_root.inserted_at < $1 ) or ((( selecto_root.inserted_at = $2 ) and ( selecto_root.id < $3 ))))))
      
        order by selecto_root.inserted_at desc, selecto_root.id desc
      
        limit 25
```

**Params:** `[~N[2024-02-01 00:00:00], ~N[2024-02-01 00:00:00], 2000]`

### SQLite

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from orders selecto_root
        where (((( selecto_root.inserted_at < ? ) or ((( selecto_root.inserted_at = ? ) and ( selecto_root.id < ? ))))))
      
        order by selecto_root.inserted_at desc, selecto_root.id desc
      
        limit 25
```

**Params:** `[~N[2024-02-01 00:00:00], ~N[2024-02-01 00:00:00], 2000]`

## T008

### PostgreSQL

```sql
(
        select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from orders selecto_root)
UNION ALL
(
        select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from archived_orders selecto_root)
ORDER BY selecto_root.inserted_at desc
limit 50
```

**Params:** `[]`

### SQLite

```sql
(
        select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from orders selecto_root)
UNION ALL
(
        select selecto_root.order_number, selecto_root.inserted_at, selecto_root.total
        from archived_orders selecto_root)
ORDER BY selecto_root.inserted_at desc
limit 50
```

**Params:** `[]`

## G001

### PostgreSQL

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( ST_DWithin(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326), 1000) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( ST_DWithin(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326), 1000) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

## G002

### PostgreSQL

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( exists (SELECT 1 FROM regions r WHERE ST_Intersects(selecto_root.geom, r.geom)) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( exists (SELECT 1 FROM regions r WHERE ST_Intersects(selecto_root.geom, r.geom)) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

## G003

### PostgreSQL

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( ST_Contains(ST_GeomFromText('POLYGON((-74.02 40.70, -73.95 40.70, -73.95 40.78, -74.02 40.78, -74.02 40.70))', 4326), selecto_root.geom) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( ST_Contains(ST_GeomFromText('POLYGON((-74.02 40.70, -73.95 40.70, -73.95 40.78, -74.02 40.78, -74.02 40.70))', 4326), selecto_root.geom) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

## G004

### PostgreSQL

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( selecto_root.geom && ST_MakeEnvelope(-74.05, 40.68, -73.90, 40.82, 4326) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( selecto_root.geom && ST_MakeEnvelope(-74.05, 40.68, -73.90, 40.82, 4326) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

## G005

### PostgreSQL

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( ST_Intersects(selecto_root.geom, ST_Buffer(ST_SetSRID(ST_MakePoint(-73.98, 40.75), 4326), 0.01)) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( ST_Intersects(selecto_root.geom, ST_Buffer(ST_SetSRID(ST_MakePoint(-73.98, 40.75), 4326), 0.01)) ))
      
        order by selecto_root.id asc
```

**Params:** `[]`

## G006

### PostgreSQL

```sql
select selecto_root.id, selecto_root.name, ST_Distance(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326))
        from locations selecto_root
        order by ST_Distance(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326)) asc
      
        limit 10
```

**Params:** `[]`

### SQLite

```sql
select selecto_root.id, selecto_root.name, ST_Distance(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326))
        from locations selecto_root
        order by ST_Distance(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326)) asc
      
        limit 10
```

**Params:** `[]`

## G007

### PostgreSQL

```sql
select ST_GeometryType(selecto_root.geom), count(*)
        from locations selecto_root
        group by ST_GeometryType(selecto_root.geom)
      
        order by ST_GeometryType(selecto_root.geom) asc
```

**Params:** `[]`

### SQLite

```sql
select ST_GeometryType(selecto_root.geom), count(*)
        from locations selecto_root
        group by ST_GeometryType(selecto_root.geom)
      
        order by ST_GeometryType(selecto_root.geom) asc
```

**Params:** `[]`

## G008

### PostgreSQL

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( exists (SELECT 1 FROM regions r WHERE ST_Intersects(selecto_root.geom, r.geom) AND r.kind = $1) ))
      
        order by selecto_root.id asc
```

**Params:** `["delivery"]`

### SQLite

```sql
select selecto_root.id, selecto_root.name
        from locations selecto_root
        where (( exists (SELECT 1 FROM regions r WHERE ST_Intersects(selecto_root.geom, r.geom) AND r.kind = ?) ))
      
        order by selecto_root.id asc
```

**Params:** `["delivery"]`

## C001

### PostgreSQL

```sql
WITH order_totals (id, total) AS (
    
        select selecto_root.id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.status = $1 ))
      
)

        select selecto_root.order_number, order_totals.total
        from orders selecto_root left join order_totals order_totals on order_totals.id = selecto_root.id
```

**Params:** `["delivered"]`

### SQLite

```sql
WITH order_totals (id, total) AS (
    
        select selecto_root.id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.status = ? ))
      
)

        select selecto_root.order_number, order_totals.total
        from orders selecto_root left join order_totals order_totals on order_totals.id = selecto_root.id
```

**Params:** `["delivered"]`

## C002

### PostgreSQL

```sql
WITH RECURSIVE order_chain (id, status) AS (
    
        select selecto_root.id, selecto_root.status
        from orders selecto_root
        where (( selecto_root.status = $1 ))
      
    UNION ALL
    
        select selecto_root.id, selecto_root.status
        from orders selecto_root
)

        select selecto_root.order_number, order_chain.status
        from orders selecto_root left join order_chain order_chain on order_chain.id = selecto_root.id
```

**Params:** `["processing"]`

### SQLite

```sql
WITH RECURSIVE order_chain (id, status) AS (
    
        select selecto_root.id, selecto_root.status
        from orders selecto_root
        where (( selecto_root.status = ? ))
      
    UNION ALL
    
        select selecto_root.id, selecto_root.status
        from orders selecto_root
)

        select selecto_root.order_number, order_chain.status
        from orders selecto_root left join order_chain order_chain on order_chain.id = selecto_root.id
```

**Params:** `["processing"]`

## C003

### PostgreSQL

```sql
WITH customer_spend (customer_id, total) AS (
    
        select selecto_root.customer_id, selecto_root.total
        from orders selecto_root
),
    order_totals (id, total) AS (
    
        select selecto_root.id, selecto_root.total
        from orders selecto_root
)

        select selecto_root.order_number, order_totals.total, customer_spend.total
        from orders selecto_root left join order_totals order_totals on order_totals.id = selecto_root.id left join customer_spend customer_spend on customer_spend.customer_id = selecto_root.customer_id
```

**Params:** `[]`

### SQLite

```sql
WITH customer_spend (customer_id, total) AS (
    
        select selecto_root.customer_id, selecto_root.total
        from orders selecto_root
),
    order_totals (id, total) AS (
    
        select selecto_root.id, selecto_root.total
        from orders selecto_root
)

        select selecto_root.order_number, order_totals.total, customer_spend.total
        from orders selecto_root left join order_totals order_totals on order_totals.id = selecto_root.id left join customer_spend customer_spend on customer_spend.customer_id = selecto_root.customer_id
```

**Params:** `[]`

## C004

### PostgreSQL

```sql
WITH status_labels ("status", "status_label") AS (VALUES ('processing', 'In Progress'), ('shipped', 'In Transit'), ('delivered', 'Completed'))

        select selecto_root.order_number, status_labels.status_label
        from orders selecto_root left join status_labels status_labels on status_labels.status = selecto_root.status
```

**Params:** `[]`

### SQLite

```sql
WITH status_labels ("status", "status_label") AS (VALUES ('processing', 'In Progress'), ('shipped', 'In Transit'), ('delivered', 'Completed'))

        select selecto_root.order_number, status_labels.status_label
        from orders selecto_root left join status_labels status_labels on status_labels.status = selecto_root.status
```

**Params:** `[]`

## C005

### PostgreSQL

```sql
WITH order_totals (id, total) AS (
    
        select selecto_root.id, selecto_root.total
        from orders selecto_root
)

        select selecto_root.order_number, order_totals.total
        from orders selecto_root left join order_totals order_totals on order_totals.id = selecto_root.id
```

**Params:** `[]`

### SQLite

```sql
WITH order_totals (id, total) AS (
    
        select selecto_root.id, selecto_root.total
        from orders selecto_root
)

        select selecto_root.order_number, order_totals.total
        from orders selecto_root left join order_totals order_totals on order_totals.id = selecto_root.id
```

**Params:** `[]`

## C006

### PostgreSQL

```sql
WITH status_labels ("status", "status_label") AS (VALUES ('processing', 'In Progress'), ('shipped', 'In Transit'))

        select selecto_root.order_number, status_labels.status_label
        from orders selecto_root left join status_labels status_labels on status_labels.status = selecto_root.status
```

**Params:** `[]`

### SQLite

```sql
WITH status_labels ("status", "status_label") AS (VALUES ('processing', 'In Progress'), ('shipped', 'In Transit'))

        select selecto_root.order_number, status_labels.status_label
        from orders selecto_root left join status_labels status_labels on status_labels.status = selecto_root.status
```

**Params:** `[]`

## C007

### PostgreSQL

```sql
WITH RECURSIVE order_chain (id, status) AS (
    
        select selecto_root.id, selecto_root.status
        from orders selecto_root
        where (( selecto_root.status = $1 ))
      
    UNION ALL
    
        select selecto_root.id, selecto_root.status
        from orders selecto_root
)

        select selecto_root.order_number, order_chain.status
        from orders selecto_root left join order_chain order_chain on order_chain.id = selecto_root.id
```

**Params:** `["processing"]`

### SQLite

```sql
WITH RECURSIVE order_chain (id, status) AS (
    
        select selecto_root.id, selecto_root.status
        from orders selecto_root
        where (( selecto_root.status = ? ))
      
    UNION ALL
    
        select selecto_root.id, selecto_root.status
        from orders selecto_root
)

        select selecto_root.order_number, order_chain.status
        from orders selecto_root left join order_chain order_chain on order_chain.id = selecto_root.id
```

**Params:** `["processing"]`

## C008

### PostgreSQL

```sql
WITH status_labels ("status", "status_label") AS (VALUES ('processing', 'In Progress'), ('shipped', 'In Transit'), ('delivered', 'Completed'))

        select selecto_root.order_number, selecto_root.status, status_labels.status_label
        from orders selecto_root left join status_labels status_labels on status_labels.status = selecto_root.status
```

**Params:** `[]`

### SQLite

```sql
WITH status_labels ("status", "status_label") AS (VALUES ('processing', 'In Progress'), ('shipped', 'In Transit'), ('delivered', 'Completed'))

        select selecto_root.order_number, selecto_root.status, status_labels.status_label
        from orders selecto_root left join status_labels status_labels on status_labels.status = selecto_root.status
```

**Params:** `[]`

