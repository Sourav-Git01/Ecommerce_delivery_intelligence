USE ecommerce_delivery_intelligence;


# Seller-level late-delivery analysis


SELECT
    OSD.seller_id,
    COUNT(DISTINCT OOD.order_id) AS total_orders,
    COUNT(
        DISTINCT CASE
            WHEN DATEDIFF(
                OOD.order_delivered_customer_date,
                OOD.order_estimated_delivery_date
            ) > 0
            THEN OOD.order_id
        END
    ) AS late_orders,
    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN DATEDIFF(
                    OOD.order_delivered_customer_date,
                    OOD.order_estimated_delivery_date
                ) > 0
                THEN OOD.order_id
            END
        ) * 100.0
        / COUNT(DISTINCT OOD.order_id),
        2
    ) AS late_percent
FROM olist_orders_dataset AS OOD

JOIN olist_order_items_dataset AS OOID
    ON OOD.order_id = OOID.order_id

JOIN olist_sellers_dataset AS OSD
    ON OOID.seller_id = OSD.seller_id

JOIN olist_customers_dataset AS OCD
    ON OOD.customer_id = OCD.customer_id

WHERE OOD.order_status = 'delivered'
  AND OOD.order_delivered_customer_date IS NOT NULL
  AND OCD.customer_state = 'SP'
  AND OOD.order_purchase_timestamp >= '2018-08-01'
  AND OOD.order_purchase_timestamp < '2018-09-01'
GROUP BY OSD.seller_id
ORDER BY late_orders DESC;


# least 20 orders and a late-delivery rate above 10%

SELECT OSD.seller_id, count(distinct OOD.order_id) as total,
Count( distinct CASE WHEN DATEDIFF(OOD.order_delivered_customer_date,OOD.order_estimated_delivery_date)>0 
then OOD.order_id end) as late_order,
Round(COUNT(distinct
 Case 
 when DATEDIFF(OOD.order_delivered_customer_date,OOD.order_estimated_delivery_date)>0 then OOD.order_id end)*100.0/
count(distinct OOD.order_id),2) as late_percent 
FROM
olist_orders_dataset OOD
JOIN olist_order_items_dataset OOID 
ON OOD.order_id=OOID.order_id
JOIN olist_customers_dataset OCD 
ON OOD.customer_id=OCD.customer_id
JOIN olist_sellers_dataset OSD
ON OOID.seller_id=OSD.seller_id
Where OOD.order_delivered_customer_date is not null and OOD.order_status='delivered'
AND ocd.customer_state='SP' AND order_purchase_timestamp >= '2018-08-01'
AND order_purchase_timestamp < '2018-09-01'
GROUP BY OSD.seller_id
HAVING COUNT(DISTINCT OOD.order_id) >= 20
   AND COUNT(DISTINCT CASE
       WHEN DATEDIFF(
           OOD.order_delivered_customer_date,
           OOD.order_estimated_delivery_date
       ) > 0
       THEN OOD.order_id
   END) * 100.0 / COUNT(DISTINCT OOD.order_id) > 10
ORDER BY late_percent DESC;


#  Investigate seller 16090f2ca825584b5a147ab24aa30c86
# by customer state for orders purchased in August 2018. and then modified it for state


SELECT
    OSD.seller_id,
    COUNT(DISTINCT OOD.order_id) AS total_orders,
    OCD.customer_state,
    COUNT(DISTINCT CASE
        WHEN DATEDIFF(
            OOD.order_delivered_customer_date,
            OOD.order_estimated_delivery_date
        ) > 0
        THEN OOD.order_id
    END) AS late_orders,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN DATEDIFF(
                OOD.order_delivered_customer_date,
                OOD.order_estimated_delivery_date
            ) > 0
            THEN OOD.order_id
        END) * 100.0
        / COUNT(DISTINCT OOD.order_id),
        2
    ) AS late_percent
FROM olist_orders_dataset AS OOD

JOIN olist_order_items_dataset AS OOID
    ON OOD.order_id = OOID.order_id

JOIN olist_sellers_dataset AS OSD
    ON OOID.seller_id = OSD.seller_id

JOIN olist_products_dataset AS OPD
    ON OOID.product_id = OPD.product_id

JOIN olist_customers_dataset AS OCD
    ON OOD.customer_id = OCD.customer_id

WHERE OOD.order_status = 'delivered'
  AND OOD.order_delivered_customer_date IS NOT NULL
  AND OOD.order_purchase_timestamp >= '2018-08-01'
  AND OOD.order_purchase_timestamp < '2018-09-01'
  AND OSD.seller_id = '16090f2ca825584b5a147ab24aa30c86'
GROUP BY
    OSD.seller_id, OCD.customer_state
ORDER BY late_percent DESC;


# -- Compare the selected seller with the overall SP benchmark for August 2018. The benchmark includes the selected seller.

SELECT COUNT(distinct order_id) as Total_order,
COUNT(distinct 
CASE WHEN datediff(ood.order_delivered_customer_date,ood.order_estimated_delivery_date)>0 then ood.order_id end) as late_orders,
ROUND(COUNT(distinct 
CASE WHEN datediff(ood.order_delivered_customer_date,ood.order_estimated_delivery_date)>0 then ood.order_id end)
*100.0/count(distinct ood.order_id),2) as late_percentage
FROM olist_orders_dataset OOD
JOIN olist_customers_dataset OCD 
ON OOD.customer_id=OCD.customer_id
WHERE ood.order_status='delivered' and ood.order_delivered_customer_date is not null
and ocd.customer_state='SP'
and  OOD.order_purchase_timestamp >= '2018-08-01'
AND OOD.order_purchase_timestamp < '2018-09-01'




# seller late delivery days, were they late from starting or they become late later

SELECT OSD.seller_id,OOD.order_id,OOD.order_purchase_timestamp,OOD.order_approved_at,OOID.shipping_limit_date,
OOD.order_delivered_carrier_date,OOD.order_delivered_customer_date,
DATEDIFF(
        OOD.order_delivered_carrier_date,
        OOD.order_approved_at
    ) AS approval_to_carrier_days,
DATEDIFF(
        OOD.order_delivered_customer_date,
        OOD.order_delivered_carrier_date
    ) AS carrier_to_customer_days,
DATEDIFF(
        OOD.order_delivered_customer_date,
        OOD.order_estimated_delivery_date
    ) AS delivery_vs_estimate_days

FROM olist_orders_dataset AS OOD

JOIN olist_order_items_dataset AS OOID
    ON OOD.order_id = OOID.order_id

JOIN olist_sellers_dataset AS OSD
    ON OOID.seller_id = OSD.seller_id

WHERE OOD.order_status = 'delivered'
  AND OOD.order_delivered_customer_date IS NOT NULL
  AND OOD.order_purchase_timestamp >= '2018-08-01'
  AND OOD.order_purchase_timestamp < '2018-09-01'
  AND OSD.seller_id = '16090f2ca825584b5a147ab24aa30c86'

ORDER BY OOD.order_purchase_timestamp;


#

SELECT OSD.seller_id,
CASE WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 'LATE' else 'ON TIME' end as delivery_status,
COUNT(DISTINCT OOD.order_id) AS total_orders,
AVG( DATEDIFF( OOD.order_delivered_customer_date, OOD.order_delivered_carrier_date ) ) AS avg_carrier_to_customer_days
FROM olist_orders_dataset AS OOD

JOIN olist_order_items_dataset AS OOID
    ON OOD.order_id = OOID.order_id

JOIN olist_sellers_dataset AS OSD
    ON OOID.seller_id = OSD.seller_id

WHERE OOD.order_status = 'delivered'
  AND OOD.order_delivered_customer_date IS NOT NULL
  AND OOD.order_purchase_timestamp >= '2018-08-01'
  AND OOD.order_purchase_timestamp < '2018-09-01'
  AND OSD.seller_id = '16090f2ca825584b5a147ab24aa30c86'

GROUP BY osd.seller_id,delivery_status







SELECT
    CASE
        WHEN DATEDIFF(
            order_delivered_customer_date,
            order_estimated_delivery_date
        ) > 0 THEN 'LATE'
        ELSE 'ON TIME'
    END AS delivery_status,
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL
  AND order_purchase_timestamp >= '2018-08-01'
  AND order_purchase_timestamp < '2018-09-01'
  AND order_id IN (
      SELECT order_id
      FROM olist_order_items_dataset
      WHERE seller_id = '16090f2ca825584b5a147ab24aa30c86'
  )
GROUP BY delivery_status;




# Calculate the average without duplicate order rows

WITH order_level AS (
    SELECT
        OOD.order_id,

        CASE
            WHEN DATEDIFF(
                OOD.order_delivered_customer_date,
                OOD.order_estimated_delivery_date
            ) > 0 THEN 'LATE'
            ELSE 'ON TIME'
        END AS delivery_status,

        OOD.order_delivered_carrier_date,
        OOD.order_delivered_customer_date

    FROM olist_orders_dataset AS OOD

    WHERE OOD.order_status = 'delivered'
      AND OOD.order_delivered_customer_date IS NOT NULL
      AND OOD.order_delivered_carrier_date IS NOT NULL
      AND OOD.order_purchase_timestamp >= '2018-08-01'
      AND OOD.order_purchase_timestamp < '2018-09-01'

      AND OOD.order_id IN (
          SELECT OOID.order_id
          FROM olist_order_items_dataset AS OOID
          WHERE OOID.seller_id = '16090f2ca825584b5a147ab24aa30c86'
      )
)

SELECT
    delivery_status,
    COUNT(*) AS total_orders,

    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_delivered_carrier_date
            )
        ),
        2
    ) AS avg_carrier_to_customer_days

FROM order_level

GROUP BY delivery_status

ORDER BY delivery_status;



# Where does the delay develop?

-- Where does the delay develop?
-- Compare approval-to-carrier and carrier-to-customer time.

WITH order_level AS (
SELECT
OOD.order_id, CASE WHEN DATEDIFF(OOD.order_delivered_customer_date,OOD.order_estimated_delivery_date) > 0 THEN 'LATE'
ELSE 'ON TIME'END AS delivery_status,

DATEDIFF(OOD.order_delivered_carrier_date,OOD.order_approved_at) AS approved_to_carrier_days,

DATEDIFF(OOD.order_delivered_customer_date,OOD.order_delivered_carrier_date) AS carrier_to_customer_days

FROM olist_orders_dataset AS OOD

WHERE OOD.order_status = 'delivered'
  AND OOD.order_delivered_customer_date IS NOT NULL
  AND OOD.order_delivered_carrier_date IS NOT NULL
  AND OOD.order_approved_at IS NOT NULL
  AND OOD.order_purchase_timestamp >= '2018-08-01'
  AND OOD.order_purchase_timestamp < '2018-09-01'

  AND OOD.order_id IN (
      SELECT OOID.order_id
      FROM olist_order_items_dataset AS OOID
      WHERE OOID.seller_id = '16090f2ca825584b5a147ab24aa30c86'
  )

)

SELECT
delivery_status,
COUNT(*) AS total_orders,
ROUND(AVG(approved_to_carrier_days), 2)
AS avg_approved_to_carrier_days,
ROUND(AVG(carrier_to_customer_days), 2)
AS avg_carrier_to_customer_days

FROM order_level
GROUP BY delivery_status
ORDER BY delivery_status;



# id the seller hand over orders to the carrier before the shipping deadline?

#Business Question:Did the carrier receive the seller's orders after the latest shipping deadline among the order's items?

WITH order_deadlines AS (
    SELECT
        order_id,
        MAX(shipping_limit_date) AS latest_shipping_deadline
    FROM olist_order_items_dataset
    WHERE seller_id = '16090f2ca825584b5a147ab24aa30c86'
    GROUP BY order_id
)

SELECT
    CASE
        WHEN od.latest_shipping_deadline IS NULL
          OR o.order_delivered_carrier_date IS NULL
            THEN 'Missing Timestamp'

        WHEN o.order_delivered_carrier_date
             > od.latest_shipping_deadline
            THEN 'Handoff After Latest Deadline'

        ELSE 'Handoff On or Before Latest Deadline'
    END AS handoff_status,

    COUNT(*) AS total_orders

FROM order_deadlines od

JOIN olist_orders_dataset o
    ON od.order_id = o.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp >= '2018-08-01'
  AND o.order_purchase_timestamp < '2018-09-01'

GROUP BY handoff_status
ORDER BY handoff_status;