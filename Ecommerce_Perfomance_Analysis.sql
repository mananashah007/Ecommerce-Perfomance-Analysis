select * from website_sessions
where utm_source = 'gsearch';

select * from orders;
-- gsearch trend for orders and sessions on month-year basis
select date_format(o.created_at,'%Y%m') as month_year,
-- month(o.created_at) as months,
-- year(o.created_at) as years,
count(distinct o.order_id) as gsearch_orders
-- count(distinct o.website_session_id) as sessions
from orders o 
left join website_sessions w
using (website_session_id)
where w.utm_source = 'gsearch'
and o.created_at < '2012-11-27'
group by 1
order by 1;

-- gesarch orders trend separted by brand and nonbrand campaign
select date_format(o.created_at,'%Y%m') as month_year,
-- w.utm_campaign,
count(distinct o.order_id) as total_orders,
count(distinct case when w.utm_campaign = 'brand' then o.order_id else null end) as brand_orders,
count(distinct case when w.utm_campaign = 'nonbrand' then o.order_id else null end) as non_brand_orders
from orders o
left join website_sessions w
using (website_session_id)
where utm_source = 'gsearch'
and o.created_at < '2012-11-27'
group by 1;

-- gsearch and nonbrand orders split by device type monthly trend
select date_format(o.created_at,'%Y%m') as month_year,
-- count(distinct o.order_id) as total_orders,
count(distinct case when w.utm_campaign = 'nonbrand' then o.order_id else null end) as total_non_brand_orders,
count(distinct case when w.device_type = 'desktop' then o.order_id else null end) as desktop_orders,
count(distinct case when w.device_type = 'mobile' then o.order_id else null end) as mobile_orders
from orders o
left join website_sessions w
using (website_session_id)
where w.utm_source= 'gsearch'
and o.created_at < '2012-11-27'
group by 1;