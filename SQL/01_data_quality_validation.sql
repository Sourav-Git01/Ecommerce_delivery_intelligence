# Initial Data Validation

USE ecommerce_delivery_intelligence;

SELECT 'customers' AS dataset, COUNT(*) AS total_rows
FROM olist_customers_dataset

UNION ALL

SELECT 'geolocation', COUNT(*)
FROM olist_geolocation_dataset

UNION ALL

SELECT 'order_items', COUNT(*)
FROM olist_order_items_dataset

UNION ALL

SELECT 'payments', COUNT(*)
FROM olist_order_payments_dataset

UNION ALL

SELECT 'reviews', COUNT(*)
FROM olist_order_reviews_dataset

UNION ALL

SELECT 'orders', COUNT(*)
FROM olist_orders_dataset

UNION ALL

SELECT 'products', COUNT(*)
FROM olist_products_dataset

UNION ALL

SELECT 'sellers', COUNT(*)
FROM olist_sellers_dataset

UNION ALL

SELECT 'category_translation', COUNT(*)
FROM product_category_name_translation



# CHECK whether order IDs are unique

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_ids
FROM olist_orders_dataset;



# COUNT ORDERS BY STATUS 

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;



# Check missing timestamps in the orders table

SELECT
    COUNT(*) AS total_orders,
    SUM(order_purchase_timestamp IS NULL) AS missing_purchase_timestamps,
    SUM(order_delivered_customer_date IS NULL) AS missing_delivery_timestamps,
    SUM(order_estimated_delivery_date IS NULL) AS missing_estimated_dates
FROM olist_orders_dataset;




# missing delivery dates by order status

SELECT
    order_status,
    COUNT(*) AS total_orders,
    SUM(order_delivered_customer_date IS NULL) AS missing_delivery_dates
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;




# delivered orders with missing actual delivery dates

SELECT *
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;




# Missing Orders Percetage 

SELECT
    order_status,
    COUNT(*) AS total_orders,
    SUM(CASE
        WHEN order_delivered_customer_date IS NULL THEN 1
        ELSE 0
    END) AS missing_dates,
    ROUND(
        SUM(CASE
            WHEN order_delivered_customer_date IS NULL THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS missing_percentage
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;





# delivered orders with missing customer delivery timestamps

SELECT
    o.order_id,
    o.order_status,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    COUNT(DISTINCT oi.order_item_id) AS total_order_items,
    COUNT(DISTINCT r.review_id) AS total_reviews
FROM olist_orders_dataset AS o
LEFT JOIN olist_order_items_dataset AS oi
    ON o.order_id = oi.order_id
LEFT JOIN olist_order_reviews_dataset AS r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NULL
GROUP BY
    o.order_id,
    o.order_status,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date;



# Cancelled Order With Delivery Date 

SELECT COUNT(*) AS total_canceled_orders,
SUM(CASE WHEN order_delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END) AS canceled_orders_with_delivery_timestamp,
ROUND(SUM(CASE WHEN order_delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS percentage_with_delivery_timestamp
FROM olist_orders_dataset
WHERE order_status = 'canceled';



# Among canceled orders that have a customer delivery timestamp, 
#how many were delivered before, on, or after their estimated delivery date?

SELECT
order_id,
order_delivered_customer_date,
order_estimated_delivery_date,
DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date) AS act_est_diff,
CASE WHEN DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date)>0 then "Late"
WHEN DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date)<0 then "EARLY" ELSE "ON TIME"
END AS delivery_status
FROM olist_orders_dataset
WHERE order_status="canceled" and order_delivered_customer_date IS NOT NULL


# How many canceled orders have a customer delivery timestamp, and what percentage of all canceled orders do they represent?

SELECT order_status,
count(*),
ROUND(SUM(CASE WHEN order_status="canceled" AND order_delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END)*100.0/count(*),2) as prct
FROM olist_orders_dataset
group by order_status
having order_status="canceled"