-- カテゴリ分析に使用する4テーブルの結合結果を確認
SELECT
    o.order_id,
    o.order_status,
    t.product_category_name_english,
    oi.price
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
    ON o.order_id = oi.order_id
LEFT JOIN `olist-bigquery-analysis-508805.olist.products` AS p
    ON oi.product_id = p.product_id
LEFT JOIN `olist-bigquery-analysis-508805.olist.product_category_name_translation` AS t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
LIMIT 10;

-- 配送完了注文について、英語の商品カテゴリごとの売上を集計し、売上が高い順に並べる
SELECT
    t.product_category_name_english,
    ROUND(SUM(oi.price), 2) AS category_sales
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
    ON o.order_id = oi.order_id
LEFT JOIN `olist-bigquery-analysis-508805.olist.products` AS p
    ON oi.product_id = p.product_id
LEFT JOIN `olist-bigquery-analysis-508805.olist.product_category_name_translation` AS t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY t.product_category_name_english
ORDER BY category_sales DESC;

-- 英語カテゴリがNULLとなっている原因別に商品明細数を集計
WITH category_missing AS (
    SELECT
        p.product_id,
        CASE
            WHEN p.product_category_name IS NULL THEN '元カテゴリなし'
            WHEN p.product_category_name IS NOT NULL
             AND t.product_category_name_english IS NULL THEN '翻訳なし'
            ELSE 'その他'
        END AS category_missing_reason
    FROM `olist-bigquery-analysis-508805.olist.orders` AS o
    LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
       ON o.order_id = oi.order_id
    LEFT JOIN `olist-bigquery-analysis-508805.olist.products` AS p
       ON oi.product_id = p.product_id
    LEFT JOIN `olist-bigquery-analysis-508805.olist.product_category_name_translation` AS t
       ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
      AND t.product_category_name_english IS NULL
)

SELECT
    category_missing_reason,
    COUNT(*) AS missing_row_count
FROM category_missing
GROUP BY category_missing_reason
ORDER BY missing_row_count DESC;

-- 「翻訳なし」に該当する元の商品カテゴリを確認
SELECT
    p.product_category_name,
    COUNT(*) AS missing_row_count
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
    ON o.order_id = oi.order_id
LEFT JOIN `olist-bigquery-analysis-508805.olist.products` AS p
    ON oi.product_id = p.product_id
LEFT JOIN `olist-bigquery-analysis-508805.olist.product_category_name_translation` AS t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
  AND t.product_category_name_english IS NULL
GROUP BY p.product_category_name
ORDER BY missing_row_count DESC;

-- 英語カテゴリがNULLの商品明細数と売上を原因別に集計
WITH category_missing AS (
    SELECT
        p.product_id,
        oi.price,
        CASE
            WHEN p.product_category_name IS NULL THEN '元カテゴリなし'
            WHEN p.product_category_name IS NOT NULL
             AND t.product_category_name_english IS NULL THEN '翻訳なし'
            ELSE 'その他'
        END AS category_missing_reason
    FROM `olist-bigquery-analysis-508805.olist.orders` AS o
    LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
       ON o.order_id = oi.order_id
    LEFT JOIN `olist-bigquery-analysis-508805.olist.products` AS p
       ON oi.product_id = p.product_id
    LEFT JOIN `olist-bigquery-analysis-508805.olist.product_category_name_translation` AS t
       ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
      AND t.product_category_name_english IS NULL
)

SELECT
    category_missing_reason,
    COUNT(*) AS missing_row_count,
    ROUND(SUM(price), 2) AS missing_sales
FROM category_missing
GROUP BY category_missing_reason
ORDER BY missing_sales DESC;

-- カテゴリ別売上TOP10について、売上・注文数・1注文あたりカテゴリ売上を集計
SELECT
    t.product_category_name_english AS category_name_english,
    ROUND(SUM(oi.price), 2) AS category_sales,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SAFE_DIVIDE(SUM(oi.price), COUNT(DISTINCT o.order_id)), 2) AS sales_per_order
FROM `olist-bigquery-analysis-508805.olist.orders` AS o
LEFT JOIN `olist-bigquery-analysis-508805.olist.order_items` AS oi
    ON o.order_id = oi.order_id
LEFT JOIN `olist-bigquery-analysis-508805.olist.products` AS p
    ON oi.product_id = p.product_id
LEFT JOIN `olist-bigquery-analysis-508805.olist.product_category_name_translation` AS t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
    AND t.product_category_name_english IS NOT NULL
GROUP BY category_name_english
ORDER BY category_sales DESC
LIMIT 10;
