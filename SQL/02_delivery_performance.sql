USE ecommerce_delivery_intelligence;


# Calculate the delivery delay for each eligible order


SELECT
    order_id,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    DATEDIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date
    ) AS delay_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;


# Return only late orders 

SELECT
    order_id,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    DATEDIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date
    ) AS delay_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND DATEDIFF(
      order_delivered_customer_date,
      order_estimated_delivery_date
  ) > 0;


# late-delivery percentage query

SELECT
    COUNT(*) AS total_eligible_delivered_orders,
    SUM(
	CASE WHEN DATEDIFF(order_delivered_customer_date,order_estimated_delivery_date) > 0
		THEN 1 ELSE 0 END) AS total_late_orders,
ROUND(SUM(CASE WHEN DATEDIFF(
			order_delivered_customer_date,
			order_estimated_delivery_date) > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS late_delivery_percentage
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;