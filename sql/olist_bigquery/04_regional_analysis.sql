-- 地域分析に使用する orders と customers の結合結果を確認
SELECT
    o.order_id,
    o.customer_id,
    c.customer_city,
    c.customer_state
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.customers` AS c
    ON o.customer_id = c.customer_id
LIMIT 10;

-- 州別の売上・注文数・1注文あたり売上を集計
SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS state_sales,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(
         SAFE_DIVIDE(
            SUM(oi.price), COUNT(DISTINCT o.order_id)
         ), 2
    ) AS sales_per_order
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
    ON o.order_id = oi.order_id
LEFT JOIN `olist-bigquery-analysis-508805.olist.customers` AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state 
ORDER BY state_sales DESC;

-- 配送完了注文の商品売上について州別の売上構成比を算出
WITH state_summary AS (
    SELECT
        c.customer_state,
        ROUND(SUM(oi.price), 2) AS state_sales
    FROM `olist-bigquery-analysis-508805.olist.orders` AS o
    LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
        ON o.order_id = oi.order_id
    LEFT JOIN `olist-bigquery-analysis-508805.olist.customers` AS c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
)

SELECT
    customer_state,
    state_sales,
    ROUND(
        SAFE_DIVIDE(
            state_sales,
            SUM(state_sales) OVER ()
        ) * 100,
        2
    ) AS sales_share
FROM state_summary
ORDER BY state_sales DESC;
