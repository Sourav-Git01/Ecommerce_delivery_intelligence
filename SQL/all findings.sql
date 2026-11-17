USE ecommerce_delivery_intelligence;

# Initial Data Validation

-- SELECT 'customers' AS dataset, COUNT(*) AS total_rows
-- FROM olist_customers_dataset

-- UNION ALL

-- SELECT 'geolocation', COUNT(*)
-- FROM olist_geolocation_dataset

-- UNION ALL

-- SELECT 'order_items', COUNT(*)
-- FROM olist_order_items_dataset

-- UNION ALL

-- SELECT 'payments', COUNT(*)
-- FROM olist_order_payments_dataset

-- UNION ALL

-- SELECT 'reviews', COUNT(*)
-- FROM olist_order_reviews_dataset

-- UNION ALL

-- SELECT 'orders', COUNT(*)
-- FROM olist_orders_dataset

-- UNION ALL

-- SELECT 'products', COUNT(*)
-- FROM olist_products_dataset

-- UNION ALL

-- SELECT 'sellers', COUNT(*)
-- FROM olist_sellers_dataset

-- UNION ALL

-- SELECT 'category_translation', COUNT(*)
-- FROM product_category_name_translation



# CHECK whether order IDs are unique

-- SELECT
--     COUNT(*) AS total_orders,
--     COUNT(DISTINCT customer_id) AS unique_customers
-- FROM olist_orders_dataset;


# COUNT ORDERS BY STATUS 

-- SELECT
--     order_status,
--     COUNT(*) AS total_orders
-- FROM olist_orders_dataset
-- GROUP BY order_status
-- ORDER BY total_orders DESC;


# Check missing timestamps in the orders table

-- SELECT
--     COUNT(*) AS total_orders,
--     SUM(order_purchase_timestamp IS NULL) AS missing_purchase_timestamps,
--     SUM(order_delivered_customer_date IS NULL) AS missing_delivery_timestamps,
--     SUM(order_estimated_delivery_date IS NULL) AS missing_estimated_dates
-- FROM olist_orders_dataset;


# missing delivery dates by order status

-- SELECT
--     order_status,
--     COUNT(*) AS total_orders,
--     SUM(order_delivered_customer_date IS NULL) AS missing_delivery_dates
-- FROM olist_orders_dataset
-- GROUP BY order_status
-- ORDER BY total_orders DESC;


# delivered orders with missing actual delivery dates

-- SELECT *
-- FROM olist_orders_dataset
-- WHERE order_status = 'delivered'
--   AND order_delivered_customer_date IS NULL;


# Missing Orders Percetage 

-- SELECT
--     order_status,
--     COUNT(*) AS total_orders,
--     SUM(CASE
--         WHEN order_delivered_customer_date IS NULL THEN 1
--         ELSE 0
--     END) AS missing_dates,
--     ROUND(
--         SUM(CASE
--             WHEN order_delivered_customer_date IS NULL THEN 1
--             ELSE 0
--         END) * 100.0 / COUNT(*),
--         2
--     ) AS missing_percentage
-- FROM olist_orders_dataset
-- GROUP BY order_status
-- ORDER BY total_orders DESC;



# Investigating the Eight Suspicious Orders

-- SELECT
--     o.order_id,
--     o.order_status,
--     o.order_delivered_carrier_date,
--     o.order_delivered_customer_date,
--     COUNT(DISTINCT oi.order_item_id) AS total_order_items,
--     COUNT(DISTINCT r.review_id) AS total_reviews
-- FROM olist_orders_dataset AS o
-- LEFT JOIN olist_order_items_dataset AS oi
--     ON o.order_id = oi.order_id
-- LEFT JOIN olist_order_reviews_dataset AS r
--     ON o.order_id = r.order_id
-- WHERE o.order_status = 'delivered'
--   AND o.order_delivered_customer_date IS NULL
-- GROUP BY
--     o.order_id,
--     o.order_status,
--     o.order_delivered_carrier_date,
--     o.order_delivered_customer_date;

# Cancelled Order With Delivery Date 

-- SELECT
-- order_id,
-- order_status,
-- order_purchase_timestamp,
-- order_delivered_carrier_date,
-- order_delivered_customer_date,
-- order_estimated_delivery_date
-- FROM olist_orders_dataset
-- WHERE order_status="canceled" and order_delivered_customer_date IS NOT NULL



# Among canceled orders that have a customer delivery timestamp, 
#how many were delivered before, on, or after their estimated delivery date?

-- SELECT
-- order_id,
-- order_delivered_customer_date,
-- order_estimated_delivery_date,
-- DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date) AS act_est_diff,
-- CASE WHEN DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date)>0 then "Late"
-- WHEN DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date)<0 then "EARLY" ELSE "ON TIME"
-- END AS delivery_status
-- FROM olist_orders_dataset
-- WHERE order_status="canceled" and order_delivered_customer_date IS NOT NULL


# How many canceled orders have a customer delivery timestamp, and what percentage of all canceled orders do they represent?

-- SELECT order_status,
-- count(*),
-- ROUND(SUM(CASE WHEN order_status="canceled" AND order_delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END)*100.0/count(*),2) as prct
-- FROM olist_orders_dataset
-- group by order_status
-- having order_status="canceled"




# Calculate the delivery delay for each eligible order

-- SELECT
--     order_id,
--     order_delivered_customer_date,
--     order_estimated_delivery_date,
--     DATEDIFF(
--         order_delivered_customer_date,
--         order_estimated_delivery_date
--     ) AS delay_days
-- FROM olist_orders_dataset
-- WHERE order_status = 'delivered'
--   AND order_delivered_customer_date IS NOT NULL;


# Return only late orders 

-- SELECT
--     order_id,
--     order_delivered_customer_date,
--     order_estimated_delivery_date,
--     DATEDIFF(
--         order_delivered_customer_date,
--         order_estimated_delivery_date
--     ) AS delay_days
-- FROM olist_orders_dataset
-- WHERE order_status = 'delivered'
--   AND order_delivered_customer_date IS NOT NULL
--   AND DATEDIFF(
--       order_delivered_customer_date,
--       order_estimated_delivery_date
--   ) > 0;


# late-delivery percentage query

-- SELECT
--     COUNT(*) AS total_eligible_delivered_orders,
--     SUM(
--         CASE
--             WHEN DATEDIFF(
--                 order_delivered_customer_date,
--                 order_estimated_delivery_date
--             ) > 0
--             THEN 1
--             ELSE 0
--         END
--     ) AS total_late_orders,
--     ROUND(
--         SUM(
--             CASE
--                 WHEN DATEDIFF(
--                     order_delivered_customer_date,
--                     order_estimated_delivery_date
--                 ) > 0
--                 THEN 1
--                 ELSE 0
--             END
--         ) * 100.0 / COUNT(*),
--         2
--     ) AS late_delivery_percentage
-- FROM olist_orders_dataset
-- WHERE order_status = 'delivered'
--   AND order_delivered_customer_date IS NOT NULL;


# categories with delivery problems

-- SELECT
--     OPD.product_category_name,
--     COUNT(DISTINCT OOD.order_id) AS total_orders,
--     COUNT(
--         DISTINCT CASE
--             WHEN DATEDIFF(
--                 OOD.order_delivered_customer_date,
--                 OOD.order_estimated_delivery_date
--             ) > 0
--             THEN OOD.order_id
--         END
--     ) AS late_orders,
--     ROUND(
--         COUNT(
--             DISTINCT CASE
--                 WHEN DATEDIFF(
--                     OOD.order_delivered_customer_date,
--                     OOD.order_estimated_delivery_date
--                 ) > 0
--                 THEN OOD.order_id
--             END
--         ) * 100.0
--         / COUNT(DISTINCT OOD.order_id),
--         2
--     ) AS late_percentage
-- FROM olist_orders_dataset AS OOD
-- JOIN olist_order_items_dataset AS OOID
--     ON OOD.order_id = OOID.order_id
-- JOIN olist_products_dataset AS OPD
--     ON OOID.product_id = OPD.product_id
-- WHERE OOD.order_status = 'delivered'
--   AND OOD.order_delivered_customer_date IS NOT NULL
-- GROUP BY OPD.product_category_name
-- ORDER BY late_orders DESC;


#Compare delivery performance by customer state

-- SELECT
--     OCD.customer_state,
--     COUNT(DISTINCT OOD.order_id) AS total_orders,
--     COUNT(
--         DISTINCT CASE
--             WHEN DATEDIFF(
--                 OOD.order_delivered_customer_date,
--                 OOD.order_estimated_delivery_date
--             ) > 0
--             THEN OOD.order_id
--         END
--     ) AS late_orders,
--     ROUND(
--         COUNT(
--             DISTINCT CASE
--                 WHEN DATEDIFF(
--                     OOD.order_delivered_customer_date,
--                     OOD.order_estimated_delivery_date
--                 ) > 0
--                 THEN OOD.order_id
--             END
--         ) * 100.0
--         / COUNT(DISTINCT OOD.order_id),
--         2
--     ) AS late_percent
-- FROM olist_orders_dataset AS OOD
-- JOIN olist_customers_dataset AS OCD
--     ON OOD.customer_id = OCD.customer_id
-- WHERE OOD.order_status = 'delivered'
--   AND OOD.order_delivered_customer_date IS NOT NULL
-- GROUP BY OCD.customer_state
-- ORDER BY late_orders DESC;


# Monthly late-delivery analysis for RJ

-- SELECT
--    OCD.customer_state, DATE_FORMAT(OOD.order_purchase_timestamp, '%Y-%m') AS order_month,
--     COUNT(DISTINCT OOD.order_id) AS total_orders,
--     COUNT(
--         DISTINCT CASE
--             WHEN DATEDIFF(
--                 OOD.order_delivered_customer_date,
--                 OOD.order_estimated_delivery_date
--             ) > 0
--             THEN OOD.order_id
--         END
--     ) AS late_orders,
--     ROUND(
--         COUNT(
--             DISTINCT CASE
--                 WHEN DATEDIFF(
--                     OOD.order_delivered_customer_date,
--                     OOD.order_estimated_delivery_date
--                 ) > 0
--                 THEN OOD.order_id
--             END
--         ) * 100.0
--         / COUNT(DISTINCT OOD.order_id),
--         2
--     ) AS late_percent
-- FROM olist_orders_dataset AS OOD

-- JOIN olist_customers_dataset AS OCD
--     ON OOD.customer_id = OCD.customer_id

-- WHERE OOD.order_status = 'delivered'
--   AND OOD.order_delivered_customer_date IS NOT NULL
--   AND OCD.customer_state = 'RJ'
--   AND OOD.order_purchase_timestamp >= '2018-01-01'
--   AND OOD.order_purchase_timestamp < '2018-09-01'
-- GROUP BY DATE_FORMAT(OOD.order_purchase_timestamp, '%Y-%m')
-- ORDER BY order_month;


#SP category analysis for August 2018

-- SELECT
--     OPD.product_category_name,
--     COUNT(DISTINCT OOD.order_id) AS total_orders,
--     COUNT(
--         DISTINCT CASE
--             WHEN DATEDIFF(
--                 OOD.order_delivered_customer_date,
--                 OOD.order_estimated_delivery_date
--             ) > 0
--             THEN OOD.order_id
--         END
--     ) AS late_orders,
--     ROUND(
--         COUNT(
--             DISTINCT CASE
--                 WHEN DATEDIFF(
--                     OOD.order_delivered_customer_date,
--                     OOD.order_estimated_delivery_date
--                 ) > 0
--                 THEN OOD.order_id
--             END
--         ) * 100.0
--         / COUNT(DISTINCT OOD.order_id),
--         2
--     ) AS late_percent
-- FROM olist_orders_dataset AS OOD

-- JOIN olist_order_items_dataset AS OOID
--     ON OOD.order_id = OOID.order_id

-- JOIN olist_products_dataset AS OPD
--     ON OOID.product_id = OPD.product_id

-- JOIN olist_customers_dataset AS OCD
--     ON OOD.customer_id = OCD.customer_id

-- WHERE OOD.order_status = 'delivered'
--   AND OOD.order_delivered_customer_date IS NOT NULL
--   AND OCD.customer_state = 'SP'
--   AND OOD.order_purchase_timestamp >= '2018-08-01'
--   AND OOD.order_purchase_timestamp < '2018-09-01'
-- GROUP BY OPD.product_category_name
-- ORDER BY late_orders DESC;


# Seller-level late-delivery analysis

-- SELECT
--     OSD.seller_id,
--     COUNT(DISTINCT OOD.order_id) AS total_orders,
--     COUNT(
--         DISTINCT CASE
--             WHEN DATEDIFF(
--                 OOD.order_delivered_customer_date,
--                 OOD.order_estimated_delivery_date
--             ) > 0
--             THEN OOD.order_id
--         END
--     ) AS late_orders,
--     ROUND(
--         COUNT(
--             DISTINCT CASE
--                 WHEN DATEDIFF(
--                     OOD.order_delivered_customer_date,
--                     OOD.order_estimated_delivery_date
--                 ) > 0
--                 THEN OOD.order_id
--             END
--         ) * 100.0
--         / COUNT(DISTINCT OOD.order_id),
--         2
--     ) AS late_percent
-- FROM olist_orders_dataset AS OOD

-- JOIN olist_order_items_dataset AS OOID
--     ON OOD.order_id = OOID.order_id

-- JOIN olist_sellers_dataset AS OSD
--     ON OOID.seller_id = OSD.seller_id

-- JOIN olist_customers_dataset AS OCD
--     ON OOD.customer_id = OCD.customer_id

-- WHERE OOD.order_status = 'delivered'
--   AND OOD.order_delivered_customer_date IS NOT NULL
--   AND OCD.customer_state = 'SP'
--   AND OOD.order_purchase_timestamp >= '2018-08-01'
--   AND OOD.order_purchase_timestamp < '2018-09-01'
-- GROUP BY OSD.seller_id
-- ORDER BY late_orders DESC;


# least 20 orders and a late-delivery rate above 10%

-- SELECT OSD.seller_id, count(distinct OOD.order_id) as total,
-- Count( distinct CASE WHEN DATEDIFF(OOD.order_delivered_customer_date,OOD.order_estimated_delivery_date)>0 
-- then OOD.order_id end) as late_order,
-- Round(COUNT(distinct
--  Case 
--  when DATEDIFF(OOD.order_delivered_customer_date,OOD.order_estimated_delivery_date)>0 then OOD.order_id end)*100.0/
-- count(distinct OOD.order_id),2) as late_percent 
-- FROM
-- olist_orders_dataset OOD
-- JOIN olist_order_items_dataset OOID 
-- ON OOD.order_id=OOID.order_id
-- JOIN olist_customers_dataset OCD 
-- ON OOD.customer_id=OCD.customer_id
-- JOIN olist_sellers_dataset OSD
-- ON OOID.seller_id=OSD.seller_id
-- Where OOD.order_delivered_customer_date is not null and OOD.order_status='delivered'
-- AND ocd.customer_state='SP' AND order_purchase_timestamp >= '2018-08-01'
-- AND order_purchase_timestamp < '2018-09-01'
-- GROUP BY OSD.seller_id
-- HAVING COUNT(DISTINCT OOD.order_id) >= 20
--    AND COUNT(DISTINCT CASE
--        WHEN DATEDIFF(
--            OOD.order_delivered_customer_date,
--            OOD.order_estimated_delivery_date
--        ) > 0
--        THEN OOD.order_id
--    END) * 100.0 / COUNT(DISTINCT OOD.order_id) > 10
-- ORDER BY late_percent DESC;


# investigation seller 16090f2ca825584b5a147ab24aa30c86 late delivery for product category and then modified it for state


-- SELECT
--     OSD.seller_id,
--     COUNT(DISTINCT OOD.order_id) AS total_orders,
--     OCD.customer_state,
--     COUNT(DISTINCT CASE
--         WHEN DATEDIFF(
--             OOD.order_delivered_customer_date,
--             OOD.order_estimated_delivery_date
--         ) > 0
--         THEN OOD.order_id
--     END) AS late_orders,
--     ROUND(
--         COUNT(DISTINCT CASE
--             WHEN DATEDIFF(
--                 OOD.order_delivered_customer_date,
--                 OOD.order_estimated_delivery_date
--             ) > 0
--             THEN OOD.order_id
--         END) * 100.0
--         / COUNT(DISTINCT OOD.order_id),
--         2
--     ) AS late_percent
-- FROM olist_orders_dataset AS OOD

-- JOIN olist_order_items_dataset AS OOID
--     ON OOD.order_id = OOID.order_id

-- JOIN olist_sellers_dataset AS OSD
--     ON OOID.seller_id = OSD.seller_id

-- JOIN olist_products_dataset AS OPD
--     ON OOID.product_id = OPD.product_id

-- JOIN olist_customers_dataset AS OCD
--     ON OOD.customer_id = OCD.customer_id

-- WHERE OOD.order_status = 'delivered'
--   AND OOD.order_delivered_customer_date IS NOT NULL
--   AND OOD.order_purchase_timestamp >= '2018-08-01'
--   AND OOD.order_purchase_timestamp < '2018-09-01'
--   AND OSD.seller_id = '16090f2ca825584b5a147ab24aa30c86'
-- GROUP BY
--     OSD.seller_id, OCD.customer_state
-- ORDER BY late_percent DESC;


# Compare the seller against the overall benchmark

-- SELECT COUNT(distinct order_id) as Total_order,
-- COUNT(distinct 
-- CASE WHEN datediff(ood.order_delivered_customer_date,ood.order_estimated_delivery_date)>0 then ood.order_id end) as late_orders,
-- ROUND(COUNT(distinct 
-- CASE WHEN datediff(ood.order_delivered_customer_date,ood.order_estimated_delivery_date)>0 then ood.order_id end)
-- *100.0/count(distinct ood.order_id),2) as late_percentage
-- FROM olist_orders_dataset OOD
-- JOIN olist_customers_dataset OCD 
-- ON OOD.customer_id=OCD.customer_id
-- WHERE ood.order_status='delivered' and ood.order_delivered_customer_date is not null
-- and ocd.customer_state='SP'
-- and  OOD.order_purchase_timestamp >= '2018-08-01'
-- AND OOD.order_purchase_timestamp < '2018-09-01'




# seller late delivery days, were they late from starting or they become late later
-- SELECT OSD.seller_id,OOD.order_id,OOD.order_purchase_timestamp,OOD.order_approved_at,OOID.shipping_limit_date,
-- OOD.order_delivered_carrier_date,OOD.order_delivered_customer_date,
-- DATEDIFF(
--         OOD.order_delivered_carrier_date,
--         OOD.order_approved_at
--     ) AS approval_to_carrier_days,
-- DATEDIFF(
--         OOD.order_delivered_customer_date,
--         OOD.order_delivered_carrier_date
--     ) AS carrier_to_customer_days,
-- DATEDIFF(
--         OOD.order_delivered_customer_date,
--         OOD.order_estimated_delivery_date
--     ) AS delivery_vs_estimate_days

-- FROM olist_orders_dataset AS OOD

-- JOIN olist_order_items_dataset AS OOID
--     ON OOD.order_id = OOID.order_id

-- JOIN olist_sellers_dataset AS OSD
--     ON OOID.seller_id = OSD.seller_id

-- WHERE OOD.order_status = 'delivered'
--   AND OOD.order_delivered_customer_date IS NOT NULL
--   AND OOD.order_purchase_timestamp >= '2018-08-01'
--   AND OOD.order_purchase_timestamp < '2018-09-01'
--   AND OSD.seller_id = '16090f2ca825584b5a147ab24aa30c86'

-- ORDER BY OOD.order_purchase_timestamp;


#

-- SELECT OSD.seller_id,
-- CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 'LATE' else 'ON TIME' end as delivery_status,
-- COUNT(DISTINCT OOD.order_id) AS total_orders,
-- AVG( DATEDIFF( OOD.order_delivered_customer_date, OOD.order_delivered_carrier_date ) ) AS avg_carrier_to_customer_days
-- FROM olist_orders_dataset AS OOD

-- JOIN olist_order_items_dataset AS OOID
--     ON OOD.order_id = OOID.order_id

-- JOIN olist_sellers_dataset AS OSD
--     ON OOID.seller_id = OSD.seller_id

-- WHERE OOD.order_status = 'delivered'
--   AND OOD.order_delivered_customer_date IS NOT NULL
--   AND OOD.order_purchase_timestamp >= '2018-08-01'
--   AND OOD.order_purchase_timestamp < '2018-09-01'
--   AND OSD.seller_id = '16090f2ca825584b5a147ab24aa30c86'

-- GROUP BY osd.seller_id,delivery_status







-- SELECT
--     CASE
--         WHEN DATEDIFF(
--             order_delivered_customer_date,
--             order_estimated_delivery_date
--         ) > 0 THEN 'LATE'
--         ELSE 'ON TIME'
--     END AS delivery_status,
--     COUNT(DISTINCT order_id) AS total_orders
-- FROM olist_orders_dataset
-- WHERE order_status = 'delivered'
--   AND order_delivered_customer_date IS NOT NULL
--   AND order_delivered_carrier_date IS NOT NULL
--   AND order_purchase_timestamp >= '2018-08-01'
--   AND order_purchase_timestamp < '2018-09-01'
--   AND order_id IN (
--       SELECT order_id
--       FROM olist_order_items_dataset
--       WHERE seller_id = '16090f2ca825584b5a147ab24aa30c86'
--   )
-- GROUP BY delivery_status;




# Calculate the average without duplicate order rows

-- WITH order_level AS (
--     SELECT
--         OOD.order_id,

--         CASE
--             WHEN DATEDIFF(
--                 OOD.order_delivered_customer_date,
--                 OOD.order_estimated_delivery_date
--             ) > 0 THEN 'LATE'
--             ELSE 'ON TIME'
--         END AS delivery_status,

--         OOD.order_delivered_carrier_date,
--         OOD.order_delivered_customer_date

--     FROM olist_orders_dataset AS OOD

--     WHERE OOD.order_status = 'delivered'
--       AND OOD.order_delivered_customer_date IS NOT NULL
--       AND OOD.order_delivered_carrier_date IS NOT NULL
--       AND OOD.order_purchase_timestamp >= '2018-08-01'
--       AND OOD.order_purchase_timestamp < '2018-09-01'

--       AND OOD.order_id IN (
--           SELECT OOID.order_id
--           FROM olist_order_items_dataset AS OOID
--           WHERE OOID.seller_id = '16090f2ca825584b5a147ab24aa30c86'
--       )
-- )

-- SELECT
--     delivery_status,
--     COUNT(*) AS total_orders,

--     ROUND(
--         AVG(
--             DATEDIFF(
--                 order_delivered_customer_date,
--                 order_delivered_carrier_date
--             )
--         ),
--         2
--     ) AS avg_carrier_to_customer_days

-- FROM order_level

-- GROUP BY delivery_status

-- ORDER BY delivery_status;



# Where does the delay develop?

 -- WITH order_level AS (
--     SELECT
--         OOD.order_id,
--         DATEDIFF(order_delivered_carrier_date,order_approved_at) as approved_to_carrier,

--         CASE
--             WHEN DATEDIFF(
--                 OOD.order_delivered_customer_date,
--                 OOD.order_estimated_delivery_date
--             ) > 0 THEN 'LATE'
--             ELSE 'ON TIME'
--         END AS delivery_status,

--         OOD.order_delivered_carrier_date,
--         OOD.order_delivered_customer_date,
--         OOD.order_approved_at

--     FROM olist_orders_dataset AS OOD

--     WHERE OOD.order_status = 'delivered'
--       AND OOD.order_delivered_customer_date IS NOT NULL
--       AND OOD.order_delivered_carrier_date IS NOT NULL
--       AND OOD.order_purchase_timestamp >= '2018-08-01'
--       AND OOD.order_purchase_timestamp < '2018-09-01'

--       AND OOD.order_id IN (
--           SELECT OOID.order_id
--           FROM olist_order_items_dataset AS OOID
--           WHERE OOID.seller_id = '16090f2ca825584b5a147ab24aa30c86'
--       )
-- )

-- SELECT
--     delivery_status,
--     COUNT(*) AS total_orders,

--     ROUND(
--         AVG(
--             DATEDIFF(
--                 order_delivered_customer_date,
--                 order_delivered_carrier_date
--             )
--         ),
--         2
--     ) AS avg_carrier_to_customer_days,
--     
--      ROUND(AVG(DATEDIFF(order_delivered_carrier_date,order_approved_at)),2) AS avg_approved_to_carrier_days

-- FROM order_level

-- GROUP BY delivery_status

-- ORDER BY delivery_status;


# id the seller hand over orders to the carrier before the shipping deadline?

SELECT
    CASE
        WHEN oi.shipping_limit_date IS NULL
          OR o.order_delivered_carrier_date IS NULL
            THEN 'Missing timestamp'
        WHEN o.order_delivered_carrier_date > oi.shipping_limit_date
            THEN 'Handoff After Deadline'
        ELSE 'Handoff On or Before Deadline'
    END AS handoff_status,

    COUNT(DISTINCT o.order_id) AS total_orders

FROM olist_orders_dataset o

JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id

WHERE oi.seller_id = '16090f2ca825584b5a147ab24aa30c86'
  AND o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp >= '2018-08-01'
  AND o.order_purchase_timestamp < '2018-09-01'

GROUP BY handoff_status;