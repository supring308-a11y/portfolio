--order_items のデータ構造を確認
SELECT
    COUNT(*) AS item_row_count,
    COUNT(DISTINCT order_id) AS unique_order_count
FROM `olist-bigquery-analysis-508805.olist.order_items`;

-- orders と order_items の結合結果を確認
SELECT
    o.order_id,
    o.order_status,
    oi.order_item_id,
    oi.price
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
    ON o.order_id = oi.order_id
LIMIT 10;

--ordersには存在するが、order_itemsに存在しない注文件数を確認
SELECT
    COUNT(DISTINCT o.order_id) AS orders_without_items
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;

-- order_items が存在しない注文を order_status 別に確認
SELECT
    o.order_status,
    COUNT(*) AS order_count
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL
GROUP BY o.order_status
ORDER BY order_count DESC;

--配送完了注文の売上総額を確認
SELECT
    ROUND(SUM(oi.price), 2) AS total_sales
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';
