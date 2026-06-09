-- Checking all tables are the expected length
SELECT 'customers'     AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'sellers',                      COUNT(*) FROM sellers
UNION ALL
SELECT 'products',                     COUNT(*) FROM products
UNION ALL
SELECT 'orders',                       COUNT(*) FROM orders
UNION ALL
SELECT 'order_items',                  COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments',               COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews',                COUNT(*) FROM order_reviews
UNION ALL
SELECT 'geolocation',                  COUNT(*) FROM geolocation
UNION ALL
SELECT 'product_category_name_translation', COUNT(*) 
FROM product_category_name_translation;

-- Orders: how many rows are missing key timestamps
SELECT
    COUNT(*)                                            AS total_orders,
    COUNT(*) FILTER (WHERE order_purchase_timestamp 
                     IS NULL)                           AS null_purchase_ts,
    COUNT(*) FILTER (WHERE order_approved_at 
                     IS NULL)                           AS null_approved,
    COUNT(*) FILTER (WHERE order_delivered_customer_date 
                     IS NULL)                           AS null_delivered,
    COUNT(*) FILTER (WHERE order_estimated_delivery_date 
                     IS NULL)                           AS null_estimated,
	ROUND((COUNT(*) FILTER (WHERE order_delivered_customer_date 
                     IS NULL OR order_approved_at 
                     IS NULL))*1.0
					 /
					 COUNT(*)*100.0, 2) AS pct_null					 
FROM orders;


-- What is the order status for orders with null delivery dates?
SELECT
    order_status,
    COUNT(*)                            AS order_count,
    ROUND(COUNT(*) * 100.0 
          / SUM(COUNT(*)) OVER(), 2)    AS pct_of_null_deliveries
FROM orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY order_count DESC;


-- Check for orders with delivery timestamp but status is not delivered. 
SELECT 
	order_id,
	order_status, 
	order_delivered_customer_date, 
	order_estimated_delivery_date
FROM orders
    WHERE order_status <> 'delivered'
      AND order_delivered_customer_date IS NOT NULL;


-- Full order status distribution
SELECT
    order_status,
    COUNT(*)                            AS order_count,
    ROUND(COUNT(*) * 100.0
          / SUM(COUNT(*)) OVER(), 2)    AS pct_of_total
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- Reviews: how many have text vs score only
SELECT
    COUNT(*)                                            AS total_reviews,
    COUNT(*) FILTER (WHERE review_comment_message 
                     IS NULL 
                     OR review_comment_message = '')    AS no_comment,
    COUNT(*) FILTER (WHERE review_comment_message 
                     IS NOT NULL 
                     AND review_comment_message != '')  AS has_comment,
	ROUND(
	COUNT(*) FILTER (WHERE review_comment_message 
                     IS NOT NULL 
                     AND review_comment_message != '')*1.0
					 /
					 COUNT(*)
					 *
					 100.0, 
					 2) AS pct_with_comment
FROM order_reviews;


-- UTF8 encoding check, make sure characters loaded correctly. 
SELECT review_comment_message
FROM order_reviews
WHERE review_comment_message IS NOT NULL
  AND review_comment_message != ''
LIMIT 5;



-- ============================================
-- Critical column null checks for seller
-- health scoring
-- ============================================

-- 1. Review score nulls
-- These directly reduce your ability to score sellers
SELECT
    COUNT(*)                                        AS total_reviews,
    COUNT(*) FILTER (WHERE review_score IS NULL)    AS null_scores,
    ROUND(COUNT(*) FILTER (WHERE review_score 
          IS NULL) * 100.0 / COUNT(*), 2)           AS pct_null
FROM order_reviews;

-- 2. Seller ID nulls in order_items
-- A null here means an item cannot be attributed
-- to any seller -- fatal for seller scoring
SELECT
    COUNT(*)                                        AS total_items,
    COUNT(*) FILTER (WHERE seller_id IS NULL)       AS null_seller_id,
    ROUND(COUNT(*) FILTER (WHERE seller_id 
          IS NULL) * 100.0 / COUNT(*), 2)           AS pct_null
FROM order_items;

-- 3. Price nulls in order_items
-- Needed for GMV and revenue metrics per seller
SELECT
    COUNT(*)                                        AS total_items,
    COUNT(*) FILTER (WHERE price IS NULL)           AS null_price,
    COUNT(*) FILTER (WHERE freight_value IS NULL)   AS null_freight,
    ROUND(COUNT(*) FILTER (WHERE price 
          IS NULL) * 100.0 / COUNT(*), 2)           AS pct_null_price
FROM order_items;



-- ============================================
-- Join health checks between critical tables
-- for seller health scoring:
-- order_reviews, order_items, orders
-- ============================================

-- Every order_item should have a matching order
SELECT COUNT(*) AS items_without_orders
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Every order should have a matching customer
SELECT COUNT(*) AS orders_without_customers
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
-- Both of the above queries should return 0

-- Reviews with no matching order in orders table
-- These reviews are not attributed to a valid order.
SELECT COUNT(*) AS reviews_without_orders
FROM order_reviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Reviews with no matching order_items row
-- These review scores cannot be attributed to any seller
SELECT COUNT(*) AS reviews_without_seller
FROM order_reviews r
LEFT JOIN order_items oi ON r.order_id = oi.order_id
WHERE oi.order_id IS NULL;

-- Orders with no matching order_items rows
-- These orders have no seller attribution at all
SELECT COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;

-- Orders with items but no review
-- Expected to be common -- quantifies how many
-- seller transactions have no satisfaction signal
SELECT COUNT(DISTINCT o.order_id) AS orders_without_reviews
FROM orders o
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE r.order_id IS NULL;

-- The full chain -- orders with both items AND reviews
-- This is your actual analytical universe for
-- seller health scoring
SELECT COUNT(DISTINCT o.order_id) AS orders_with_full_chain
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN order_reviews r ON o.order_id = r.order_id;
 