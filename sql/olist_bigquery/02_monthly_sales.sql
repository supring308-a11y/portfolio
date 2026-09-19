-- 配送完了注文の月別売上を集計
SELECT
    FORMAT_TIMESTAMP('%Y-%m', o.order_purchase_timestamp) AS purchase_month,
    ROUND(SUM(oi.price), 2) AS monthly_sales
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY purchase_month
ORDER BY purchase_month ASC;

-- 月別の売上・注文数・1注文あたり売上を集計
SELECT
    FORMAT_TIMESTAMP('%Y-%m', o.order_purchase_timestamp) AS purchase_month,
    ROUND(SUM(oi.price), 2) AS monthly_sales,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS sales_per_order
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY purchase_month
ORDER BY purchase_month ASC;

-- 月次データが連続している期間について、2017年2月〜2018年7月の前月比を計算
WITH monthly_summary AS (
    SELECT
        FORMAT_TIMESTAMP('%Y-%m', o.order_purchase_timestamp) AS purchase_month,
        ROUND(SUM(oi.price), 2) AS monthly_sales
    FROM `olist-bigquery-analysis-508805.olist.orders` AS o
    LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY purchase_month
),

monthly_comparison AS (
    SELECT
        purchase_month,
        monthly_sales,
        LAG(monthly_sales) OVER (ORDER BY purchase_month)
            AS previous_month_sales
    FROM monthly_summary
)

SELECT
    purchase_month,
    monthly_sales,
    previous_month_sales,
    ROUND(SAFE_DIVIDE(monthly_sales - previous_month_sales, previous_month_sales) * 100, 2) AS mom_rate
FROM monthly_comparison
WHERE purchase_month >= '2017-02'
  AND purchase_month <= '2018-07'
ORDER BY purchase_month;

-- 2017年2月〜2018年7月で、前月比が最も大きかった月を1件だけ取得する
WITH monthly_summary AS (
    SELECT
        FORMAT_TIMESTAMP('%Y-%m', o.order_purchase_timestamp) AS purchase_month,
        ROUND(SUM(oi.price), 2) AS monthly_sales
    FROM `olist-bigquery-analysis-508805.olist.orders` AS o
    LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY purchase_month
),

monthly_comparison AS (
    SELECT
        purchase_month,
        monthly_sales,
        LAG(monthly_sales) OVER (ORDER BY purchase_month)
            AS previous_month_sales
    FROM monthly_summary
)

SELECT
    purchase_month,
    monthly_sales,
    previous_month_sales,
    ROUND(SAFE_DIVIDE(monthly_sales - previous_month_sales, previous_month_sales) * 100, 2) AS mom_rate
FROM monthly_comparison
WHERE purchase_month >= '2017-02'
  AND purchase_month <= '2018-07'
ORDER BY mom_rate DESC
LIMIT 1;

-- 2017年2月〜2018年7月で、前月比が最も小さかった月を1件だけ取得する
WITH monthly_summary AS (
    SELECT
        FORMAT_TIMESTAMP('%Y-%m', o.order_purchase_timestamp) AS purchase_month,
        ROUND(SUM(oi.price), 2) AS monthly_sales
    FROM `olist-bigquery-analysis-508805.olist.orders` AS o
    LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY purchase_month
),

monthly_comparison AS (
    SELECT
        purchase_month,
        monthly_sales,
        LAG(monthly_sales) OVER (ORDER BY purchase_month)
            AS previous_month_sales
    FROM monthly_summary
)

SELECT
    purchase_month,
    monthly_sales,
    previous_month_sales,
    ROUND(SAFE_DIVIDE(monthly_sales - previous_month_sales, previous_month_sales) * 100, 2) AS mom_rate
FROM monthly_comparison
WHERE purchase_month >= '2017-02'
  AND purchase_month <= '2018-07'
ORDER BY mom_rate ASC
LIMIT 1;
