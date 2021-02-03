-- building conversion funnels
create temporary table website_session_level
select website_session_id,
max(lander_1) as lander_page,
max(to_products) as product_page,
max(to_mrfuzzy) as mrfuzzy_page,
max(to_cart) as cart_page,
max(to_shipping) as shipping_page,
max(to_billing) as billing_page,
max(to_thankyou) as thankyou_page
from 
(select w.website_session_id,
w.pageview_url,
case when w.pageview_url ='/lander-1' then 1 else 0 end as lander_1,
case when w.pageview_url='/products' then 1 else 0 end as to_products,
case when w.pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as to_mrfuzzy,
case when w.pageview_url='/cart' then 1 else 0 end as to_cart,
case when w.pageview_url='/shipping' then 1 else 0 end as to_shipping,
case when w.pageview_url='/billing' then 1 else 0 end as to_billing,
case when w.pageview_url='/thank-you-for-your-order' then 1 else 0 end as to_thankyou
 from website_pageviews w
 left join website_sessions ws
 using (website_session_id)
 where w.created_at > '2012-08-05'
 and w.created_at < '2012-09-05'
 and ws.utm_campaign = 'nonbrand'
 and ws.utm_source = 'gsearch'
 order by 1) as page_views
 group by 1;
 
select * from website_session_level;
select count(distinct website_session_id) as total_sessions,
count(case when product_page = 1 then website_session_id else null end) as to_product,
count(case when mrfuzzy_page = 1 then website_session_id else null end) as to_mrfuzzy,
count(case when cart_page = 1 then website_session_id else null end) as to_cart,
count(case when shipping_page = 1 then website_session_id else null end) as to_shipping,
count(case when billing_page = 1 then website_session_id else null end) as to_billing,
count(case when thankyou_page = 1 then website_session_id else null end) as to_thankyou
from website_session_level; 

-- assignment 2
-- billing and billing 2 comparison and click through rate
select min(created_at),
min(website_pageview_id)
from website_pageviews
where pageview_url = '/billing-2';
-- pv_id = 53550
-- select * from orders;
select pageview_url,
count(distinct website_session_id) as sessions,
count(distinct order_id) as orders,
count(distinct order_id)/count(distinct website_session_id) as billing_to_order_rt
from
(select w.pageview_url,
w.website_session_id,
o.order_id
from website_pageviews w
left join orders o
using (website_session_id)
where w.website_pageview_id >=53550
and w.created_at < '2012-11-10'
and w.pageview_url in ('/billing','/billing-2')
) as billing_page_orders
group by 1;