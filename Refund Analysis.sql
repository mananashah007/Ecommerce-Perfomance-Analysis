-- refund analysis
select * from order_items;
select 
order_items.order_id,
order_items.order_item_id,
order_items.price_usd,
order_items.created_at,
order_item_refunds.order_item_refund_id,
order_item_refunds.refund_amount_usd,
order_item_refunds.created_at
from order_items
left join order_item_refunds
using (order_item_id); 

-- analysing the differenct products refund rates from 2012 to 2014
select year(order_items.created_at),
month(order_items.created_at),
count(distinct case when order_items.product_id = 1 then order_item_id else null end) as p1_orders,
count(distinct case when order_items.product_id = 1 then order_item_refunds.order_item_refund_id else null end)/count(distinct case when order_items.product_id = 1 then order_item_id else null end)
as p1_refund_rate,
count(distinct case when order_items.product_id = 2 then order_item_id else null end) as p2_orders,
count(distinct case when order_items.product_id = 2 then order_item_refunds.order_item_refund_id else null end)/count(distinct case when order_items.product_id = 1 then order_item_id else null end)
as p2_refund_rate,
count(distinct case when order_items.product_id = 3 then order_item_id else null end) as p3_orders,
count(distinct case when order_items.product_id = 3 then order_item_refunds.order_item_refund_id else null end)/count(distinct case when order_items.product_id = 1 then order_item_id else null end)
as p3_refund_rate,
count(distinct case when order_items.product_id = 4 then order_item_id else null end) as p4_orders,
count(distinct case when order_items.product_id = 4 then order_item_refunds.order_item_refund_id else null end)/count(distinct case when order_items.product_id = 1 then order_item_id else null end)
as p4_refund_rate
from order_items
left join order_item_refunds
using (order_item_id)
where order_items.created_at < '2014-10-15'
group by 1,2;
