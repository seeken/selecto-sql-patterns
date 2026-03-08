# Selecto Yielded SQL

Generated from `Selecto.to_sql/1` for every example in this repository.

## J001

```sql
select selecto_root.order_number, customer.name
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( customer.id is not null ) and ( selecto_root.status = $1 ))
      
        order by selecto_root.order_number asc
```

**Params:** `["delivered"]`

## J002

```sql
select selecto_root.name, count(reviews.id)
        from products selecto_root left join reviews reviews on reviews.product_id = selecto_root.id
        group by selecto_root.name
      
        order by selecto_root.name asc
```

**Params:** `[]`

## J003

```sql
select selecto_root.name, selecto_root.tier, high_value_delivered.order_number, high_value_delivered.total
        from customers selecto_root inner join (
        select selecto_root.customer_id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        where (((( selecto_root.status = $1 ) and ( selecto_root.total > $2 ))))
      ) high_value_delivered on selecto_root.id = high_value_delivered.customer_id
```

**Params:** `["delivered", 1000]`

## J004

```sql
select selecto_root.first_name, manager.first_name
        from employees selecto_root left join employees manager on manager.id = selecto_root.manager_id
        order by selecto_root.first_name asc
```

**Params:** `[]`

## J005

```sql
select selecto_root.name
        from products selecto_root left join reviews reviews on reviews.product_id = selecto_root.id
        where (( reviews.id is null ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

## J006

```sql
select selecto_root.order_number, "customer:tier_premium".name, "customer:tier_standard".name
        from orders selecto_root left join customers "customer:tier_premium" on "customer:tier_premium".id = selecto_root.customer_id and "customer:tier_premium".tier = $1 left join customers "customer:tier_standard" on "customer:tier_standard".id = selecto_root.customer_id and "customer:tier_standard".tier = $2
```

**Params:** `["premium", "standard"]`

## J007

```sql
select selecto_root.name, delivered_stats.count
        from products selecto_root LEFT JOIN LATERAL (
        select count(*)
        from orders selecto_root
        where (( selecto_root.status = $1 ))
      ) AS delivered_stats ON true
```

**Params:** `["delivered"]`

## J008

```sql
select selecto_root.name, nil.product_tag
        from products selecto_root CROSS JOIN LATERAL UNNEST("selecto_root"."tags") AS product_tag
        where (( selecto_root.active = $1 ))
```

**Params:** `[true]`

## J009

```sql
select selecto_root.order_number, "customer:alias_a".name, "customer:alias_b".tier
        from orders selecto_root left join customers "customer:alias_a" on "customer:alias_a".id = selecto_root.customer_id left join customers "customer:alias_b" on "customer:alias_b".id = selecto_root.customer_id
```

**Params:** `[]`

## J010

```sql
select customer.name, count(*)
        from orders selecto_root LEFT JOIN customers customer ON selecto_root.customer_id = customer.id
        group by customer.name
      
        order by customer.name asc
```

**Params:** `[]`

## A001

```sql
select selecto_root.status, count(*)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

## A002

```sql
select selecto_root.customer_id, SUM(selecto_root.total)
        from orders selecto_root
        where (( selecto_root.status = $1 ))
      
        group by selecto_root.customer_id
      
        order by selecto_root.customer_id asc
```

**Params:** `["delivered"]`

## A003

```sql
select selecto_root.status, AVG(selecto_root.total)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

## A004

```sql
select customer.name, count(*)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        group by customer.name
      
        order by customer.name asc
```

**Params:** `[]`

## A005

```sql
select customer.tier, SUM(selecto_root.total)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        group by customer.tier
      
        order by customer.tier asc
```

**Params:** `[]`

## A006

```sql
select customer.tier, count(*)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( selecto_root.status = $1 ))
      
        group by customer.tier
      
        order by customer.tier asc
```

**Params:** `["delivered"]`

## A007

```sql
select selecto_root.status, SUM(selecto_root.total), count(*)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

## A008

```sql
select customer.tier, AVG(selecto_root.total)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( selecto_root.status = $1 ))
      
        group by customer.tier
      
        order by customer.tier asc
```

**Params:** `["delivered"]`

## W001

```sql
select selecto_root.first_name, selecto_root.department, selecto_root.salary, ROW_NUMBER() OVER (PARTITION BY selecto_root.department ORDER BY selecto_root.salary DESC) AS department_salary_rank
        from employees selecto_root
```

**Params:** `[]`

## W002

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, SUM(selecto_root.total) OVER (PARTITION BY selecto_root.customer_id ORDER BY selecto_root.id ASC) AS running_total
        from orders selecto_root
```

**Params:** `[]`

## W003

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, LAG(selecto_root.total) OVER (PARTITION BY selecto_root.customer_id ORDER BY selecto_root.id ASC) AS prev_total
        from orders selecto_root
```

**Params:** `[]`

## W004

```sql
select selecto_root.order_number, selecto_root.total, DENSE_RANK() OVER (ORDER BY selecto_root.total DESC) AS total_rank
        from orders selecto_root
```

**Params:** `[]`

## W005

```sql
select selecto_root.id, selecto_root.total, AVG(selecto_root.total) OVER (ORDER BY selecto_root.id ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS moving_avg_total
        from orders selecto_root
```

**Params:** `[]`

## W006

```sql
select selecto_root.first_name, selecto_root.department, selecto_root.salary, RANK() OVER (PARTITION BY selecto_root.department ORDER BY selecto_root.salary DESC) AS department_rank
        from employees selecto_root
```

**Params:** `[]`

## W007

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, LEAD(selecto_root.total) OVER (PARTITION BY selecto_root.customer_id ORDER BY selecto_root.id ASC) AS next_total
        from orders selecto_root
```

**Params:** `[]`

## W008

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total, MAX(selecto_root.total) OVER (PARTITION BY selecto_root.status) AS status_max_total
        from orders selecto_root
```

**Params:** `[]`

## S001

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (SELECT id FROM customers WHERE tier = 'gold') ))
      
        order by selecto_root.total desc
```

**Params:** `[]`

## S002

```sql
select selecto_root.name, delivered_orders.order_number, delivered_orders.total
        from customers selecto_root left join (
        select selecto_root.customer_id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        where (( selecto_root.status = $1 ))
      ) delivered_orders on selecto_root.id = delivered_orders.customer_id
        order by selecto_root.name asc
```

**Params:** `["delivered"]`

## S003

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( exists (SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = 'gold') ))
      
        order by selecto_root.total desc
```

**Params:** `[]`

## S004

```sql
select selecto_root.name
        from products selecto_root left join (
        select selecto_root.product_id
        from reviews selecto_root
        group by selecto_root.product_id
      ) reviewed_products on selecto_root.id = reviewed_products.product_id
        where (( reviewed_products.product_id is null ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

## S005

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (SELECT id FROM customers WHERE tier = $1) ))
      
        order by selecto_root.total desc
```

**Params:** `["silver"]`

## S006

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( exists (SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = $1) ))
      
        order by selecto_root.total desc
```

**Params:** `["gold"]`

## S007

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (SELECT id FROM customers WHERE tier = 'gold') ) and ( selecto_root.status = $1 ))
      
        order by selecto_root.total desc
```

**Params:** `["delivered"]`

## SO001

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

## C001

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

## C002

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

## C003

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

```sql
WITH status_labels ("status", "status_label") AS (VALUES ('processing', 'In Progress'), ('shipped', 'In Transit'), ('delivered', 'Completed'))

        select selecto_root.order_number, status_labels.status_label
        from orders selecto_root left join status_labels status_labels on status_labels.status = selecto_root.status
```

**Params:** `[]`

## C005

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

```sql
WITH status_labels ("status", "status_label") AS (VALUES ('processing', 'In Progress'), ('shipped', 'In Transit'))

        select selecto_root.order_number, status_labels.status_label
        from orders selecto_root left join status_labels status_labels on status_labels.status = selecto_root.status
```

**Params:** `[]`

## C007

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

## C008

```sql
WITH status_labels ("status", "status_label") AS (VALUES ('processing', 'In Progress'), ('shipped', 'In Transit'), ('delivered', 'Completed'))

        select selecto_root.order_number, selecto_root.status, status_labels.status_label
        from orders selecto_root left join status_labels status_labels on status_labels.status = selecto_root.status
```

**Params:** `[]`

