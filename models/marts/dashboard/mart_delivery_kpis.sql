-- Fatos agregados para o dashboard Metabase: % de pedidos atrasados e tempo médio de entrega
-- por estado do cliente - a mesma pergunta de negócio que orienta mart_late_delivery_features,
-- em formato pronto para visualização (ex.: priorizar intervenção logística por região).

WITH orders AS (
    SELECT * FROM {{ ref('fact_orders') }}
),

customers AS (
    SELECT * FROM {{ ref('dim_customers') }}
)

SELECT
    customers.estado AS estado,
    count(*) AS order_count,
    sum(case when orders.is_late then 1 else 0 end) AS late_count,
    sum(case when orders.is_late then 1 else 0 end) / nullif(count(*), 0)::float AS pct_late,
    avg(orders.delivery_days) AS avg_delivery_days,
    avg(orders.estimated_delivery_days) AS avg_estimated_delivery_days
FROM orders
LEFT JOIN customers ON orders.customer_key = customers.customer_key
WHERE orders.order_status = 'delivered'
    AND orders.order_delivered_customer_date is not null
    AND orders.order_estimated_delivery_date is not null
GROUP BY customers.estado
