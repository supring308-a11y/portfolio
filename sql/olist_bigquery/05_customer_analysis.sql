-- 配送完了注文をした顧客の人数を確認
SELECT
    COUNT(DISTINCT c.customer_unique_id) AS unique_customer_count
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.customers` AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';

-- 顧客ごとの購入回数を確認
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.customers` AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY order_count DESC;

-- 1回購入者とリピーターについて、顧客数と顧客構成比を集計
WITH customer_orders AS (
    SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
    FROM `olist-bigquery-analysis-508805.olist.orders` AS o
    LEFT JOIN `olist-bigquery-analysis-508805.olist.customers` AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

customer_summary AS (
    SELECT
        CASE
            WHEN order_count = 1 THEN 'one_time'
            WHEN order_count >= 2 THEN 'repeat'
        END AS customer_type,
        COUNT(*) AS customer_count
    FROM customer_orders
    GROUP BY customer_type
)

SELECT
    customer_type,
    customer_count,
    ROUND(
        SAFE_DIVIDE(
        customer_count,
        SUM(customer_count) OVER ()
        ) * 100,
        2
    ) AS customer_share
FROM customer_summary
ORDER BY customer_count DESC;

-- 1回購入者とリピーターについて、顧客数・売上・売上構成比を集計
WITH customer_orders AS (
        SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        ROUND(SUM(oi.price), 2) AS customer_sales
    FROM `olist-bigquery-analysis-508805.olist.orders` AS o
    LEFT JOIN `olist-bigquery-analysis-508805.olist.customers` AS c
        ON o.customer_id = c.customer_id
    LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

customer_summary AS (
    SELECT
        CASE
            WHEN order_count = 1 THEN 'one_time'
            WHEN order_count >= 2 THEN 'repeat'
        END AS customer_type,
        COUNT(*) AS customer_count,
        ROUND(SUM(customer_sales), 2) AS total_sales
    FROM customer_orders
    GROUP BY customer_type
)

SELECT
    customer_type,
    customer_count,
    total_sales,
    ROUND(
        SAFE_DIVIDE(
            total_sales,
            SUM(total_sales) OVER ()
        ) * 100,
        2
    ) AS sales_share
FROM customer_summary
ORDER BY total_sales DESC;
