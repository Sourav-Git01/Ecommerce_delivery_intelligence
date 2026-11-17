
USE ecommerce_delivery_intelligence;


# Among eligible delivered orders, what percentage arrived after their estimated delivery date, grouped by purchase month?

SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month, COUNT(DISTINCT order_id) AS total_orders,
COUNT(DISTINCT CASE WHEN DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date) > 0
        THEN order_id END) AS late_orders,
ROUND(COUNT(DISTINCT CASE WHEN DATEDIFF(
order_delivered_customer_date,
order_estimated_delivery_date) > 0 THEN order_id END) * 100.0 / COUNT(DISTINCT order_id),2) AS late_percent
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;




# categories with delivery problems
SELECT
OPD.product_category_name,
COUNT(DISTINCT OOD.order_id) AS total_orders,
COUNT(DISTINCT CASE WHEN DATEDIFF(OOD.order_delivered_customer_date,OOD.order_estimated_delivery_date) > 0
	then OOD.order_id END) AS late_orders,
    
ROUND(COUNT(DISTINCT CASE WHEN DATEDIFF(OOD.order_delivered_customer_date,OOD.order_estimated_delivery_date) > 0
THEN OOD.order_id END) * 100.0/ COUNT(DISTINCT OOD.order_id),2) AS late_percentage

FROM olist_orders_dataset AS OOD

JOIN olist_order_items_dataset AS OOID
    ON OOD.order_id = OOID.order_id
    
JOIN olist_products_dataset AS OPD
    ON OOID.product_id = OPD.product_id
    
WHERE OOD.order_status = 'delivered'
  AND OOD.order_delivered_customer_date IS NOT NULL
GROUP BY OPD.product_category_name
ORDER BY late_orders DESC;



#Compare delivery performance by customer state

SELECT
    OCD.customer_state,
    COUNT(DISTINCT OOD.order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN DATEDIFF(
                OOD.order_delivered_customer_date,
                OOD.order_estimated_delivery_date) > 0 THEN OOD.order_id END) AS late_orders,
ROUND(COUNT(DISTINCT CASE WHEN DATEDIFF(OOD.order_delivered_customer_date,OOD.order_estimated_delivery_date) > 0
			THEN OOD.order_id END) * 100.0/ COUNT(DISTINCT OOD.order_id),2) AS late_percent
FROM olist_orders_dataset AS OOD
JOIN olist_customers_dataset AS OCD
    ON OOD.customer_id = OCD.customer_id
WHERE OOD.order_status = 'delivered'
  AND OOD.order_delivered_customer_date IS NOT NULL
GROUP BY OCD.customer_state
ORDER BY late_orders DESC;




# Monthly late-delivery analysis for RJ

SELECT
OCD.customer_state, DATE_FORMAT(OOD.order_purchase_timestamp, '%Y-%m') AS order_month,
COUNT(DISTINCT OOD.order_id) AS total_orders,
COUNT(
	DISTINCT CASE
	WHEN DATEDIFF(OOD.order_delivered_customer_date,OOD.order_estimated_delivery_date) > 0
	THEN OOD.order_id END
    ) AS late_orders,
ROUND(COUNT(DISTINCT CASE WHEN DATEDIFF(OOD.order_delivered_customer_date,OOD.order_estimated_delivery_date) > 0
THEN OOD.order_id  END) * 100.0/ COUNT(DISTINCT OOD.order_id),2) AS late_percent
FROM olist_orders_dataset AS OOD

JOIN olist_customers_dataset AS OCD
    ON OOD.customer_id = OCD.customer_id

WHERE OOD.order_status = 'delivered'
  AND OOD.order_delivered_customer_date IS NOT NULL
  AND OCD.customer_state = 'RJ'
  AND OOD.order_purchase_timestamp >= '2018-01-01'
  AND OOD.order_purchase_timestamp < '2018-09-01'
GROUP BY DATE_FORMAT(OOD.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;




#SP category analysis for August 2018

SELECT
    OPD.product_category_name,
    COUNT(DISTINCT OOD.order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN DATEDIFF( OOD.order_delivered_customer_date,OOD.order_estimated_delivery_date) > 0
		THEN OOD.order_id END) AS late_orders,
    ROUND(COUNT(DISTINCT CASE WHEN DATEDIFF(OOD.order_delivered_customer_date,OOD.order_estimated_delivery_date) > 0
		THEN OOD.order_id END) * 100.0/ COUNT(DISTINCT OOD.order_id),2) AS late_percent
FROM olist_orders_dataset AS OOD

JOIN olist_order_items_dataset AS OOID
    ON OOD.order_id = OOID.order_id

JOIN olist_products_dataset AS OPD
    ON OOID.product_id = OPD.product_id

JOIN olist_customers_dataset AS OCD
    ON OOD.customer_id = OCD.customer_id

WHERE OOD.order_status = 'delivered'
  AND OOD.order_delivered_customer_date IS NOT NULL
  AND OCD.customer_state = 'SP'
  AND OOD.order_purchase_timestamp >= '2018-08-01'
  AND OOD.order_purchase_timestamp < '2018-09-01'
GROUP BY OPD.product_category_name
ORDER BY late_orders DESC;


