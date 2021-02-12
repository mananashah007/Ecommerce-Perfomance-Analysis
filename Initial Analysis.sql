select w.utm_content,
count(distinct w.website_session_id) as sessions,
count(distinct o.order_id) as orders,
count(distinct o.order_id)/count(distinct w.website_session_id) * 100 as sess_order_conversions_rate
from website_sessions w
left join orders o
on w.website_session_id=o.website_session_id
-- where w.website_session_id between 1000 and 2000
group by 1
order by 2,4 desc;

-- assignment 1
select count(distinct website_session_id) as number_of_sessions,
utm_source,
utm_campaign,
http_referer
from website_sessions
where created_at <= '2012-04-12'
group by 2,3,4
order by sessions desc;

-- assingment 2
select count(w.website_session_id) as sessions,
count(o.order_id) as orders,
count(o.order_id)/count(w.website_session_id) * 100 as session_to_order_conv_rate
 from website_sessions w
 left join orders o
 on o.website_session_id=w.website_session_id
 where w.created_at <='2012-04-14'
  and utm_source ='gsearch'
  and utm_campaign ='nonbrand';
  

select count(website_session_id) as sessions,
year(created_at) as year
from website_sessions
group by 2
order by 1 desc;

-- pivoting data using count and case method
select * from orders
limit 10;
select primary_product_id,
count(distinct case when items_purchased=1 then order_id else null end) as orders_w1_item,
count(distinct case when items_purchased=2 then order_id else null end) as orders_w2_item,
count(distinct order_id) as total
from orders
group by 1;

-- assignment 3
select min(date(created_at)) as week_start,
count(website_session_id) as sessions
from website_sessions
where utm_source='gsearch'
and utm_campaign='nonbrand'
and created_at < '2012-05-10'
group by year(created_at),week(created_at)
order by 2 desc;

-- assignment 4
select w.device_type,
count(distinct w.website_session_id) as sessions,
count(distinct o.order_id) as orders,
count(distinct o.order_id)/count(distinct w.website_session_id) * 100 as session_to_order_conv_rate
from website_sessions w
left join orders o
on w.website_session_id=o.website_session_id
where w.created_at < '2012-05-11'
and w.utm_source='gsearch'
and w.utm_campaign='nonbrand'
group by 1
order by 3;


-- assignment 4 
select min(date(created_at)) as week_start_date,
count(case when device_type='desktop' then website_session_id else null end) as dtop_sessions,
count(case when device_type='mobile' then website_session_id else null end) as mob_sessions
from website_sessions
where created_at > '2012-04-15' and created_at < '2012-06-09'
and utm_campaign='nonbrand'
and utm_source='gsearch'
group by year(created_at),week(created_at);