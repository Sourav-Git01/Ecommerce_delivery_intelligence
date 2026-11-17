# Business Question-- Do late deliveries lead to a worse customer experience?

#How many total records exist in the review table?
#How many distinct order_id values exist in that table?
#Whether the number of review records differs from the number of distinct orders.

SELECT
COUNT(*) AS total_review_records,
COUNT(DISTINCT order_id) AS unique_orders,
COUNT(review_id) AS non_null_review_ids,
COUNT(DISTINCT review_id) AS unique_review_ids
FROM olist_order_reviews_dataset;



# Are multiple review records associated with the same order?

select order_id, count(review_id) 
from olist_order_reviews_dataset
group by order_id
having count(review_id)>1

# For delivered orders with valid delivery timestamps and review records,
# what is the average review score for late deliveries versus on-time deliveries for each order ?

SELECT oord.order_id, avg(oord.review_score) as avg_review_score,
case when datediff(ood.order_delivered_customer_date,ood.order_estimated_delivery_date)<=0
 then 'ON TIME'else 'LATE' end AS delivery_status
 
FROM  
olist_orders_dataset ood
 
JOIN olist_order_reviews_dataset oord 
ON ood.order_id=oord.order_id

where oord.review_id is not null AND ood.order_delivered_customer_date is not null
group by oord.order_id,delivery_status


#Business question:
#Do late deliveries have lower average review scores than on-time deliveries?

with cte as (SELECT oord.order_id, avg(oord.review_score) as avg_review_score,
case when datediff(ood.order_delivered_customer_date,ood.order_estimated_delivery_date)<=0
 then 'ON TIME'else 'LATE' end AS delivery_status
 
FROM  
olist_orders_dataset ood
 
JOIN olist_order_reviews_dataset oord 
ON ood.order_id=oord.order_id

where oord.review_id is not null AND ood.order_delivered_customer_date is not null
group by oord.order_id,delivery_status)

select delivery_status, round(avg(avg_review_score),2), count(order_id) from cte 
group by delivery_status


# How are order-level average review scores distributed between late and on-time deliveries?

with cte as (SELECT oord.order_id, avg(oord.review_score) as avg_review_score,
case when datediff(ood.order_delivered_customer_date,ood.order_estimated_delivery_date)<=0
 then 'ON TIME'else 'LATE' end AS delivery_status
 
FROM  
olist_orders_dataset ood
 
JOIN olist_order_reviews_dataset oord 
ON ood.order_id=oord.order_id

where oord.review_id is not null AND ood.order_delivered_customer_date is not null
group by oord.order_id,delivery_status)

select delivery_status, avg_review_score, count(cte.order_id) as orders
from cte 
group by delivery_status, avg_review_score
order by delivery_status



# Score distribution percentage 

with cte as (SELECT oord.order_id, avg(oord.review_score) as avg_review_score,
case when datediff(ood.order_delivered_customer_date,ood.order_estimated_delivery_date)<=0
 then 'ON TIME'else 'LATE' end AS delivery_status
 
FROM  
olist_orders_dataset ood
 
JOIN olist_order_reviews_dataset oord 
ON ood.order_id=oord.order_id

where oord.review_id is not null AND ood.order_delivered_customer_date is not null
group by oord.order_id,delivery_status)

select delivery_status,
 round(avg_review_score,2) avg_review_score,
 round(orders*100.0/total_status_orders,2)  AS percentage_of_status_orders
from
 (select delivery_status, 
 avg_review_score, 
 count(cte.order_id) as orders,
sum(count(cte.order_id)) over (partition by delivery_status )  as total_status_orders
from cte 
group by avg_review_score,delivery_status)x
order by delivery_status,avg_review_score