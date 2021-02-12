select distinct 
pageview_url,
count(distinct website_pageviews.website_session_id) as sessions,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/count(distinct website_pageviews.website_session_id) as viewed_product_to_order_rate 
from website_pageviews
left join orders
using (website_session_id)
where pageview_url in ('/the-birthday-sugar-panda','/the-forever-love-bear','/the-hudson-river-mini-bear','/the-original-mr-fuzzy')
group by 1;

-- monthly trend of products orders,revenue and margin
select * from orders
limit 10;
select month(created_at),
year(created_at),
count(order_id) as total_orders,
sum(price_usd) as total_revenue,
sum(price_usd-cogs_usd) as margin
from orders
where created_at < '2013-01-04'
group by 1,2; 

-- analysing the product path analysis
drop table products_pageviews;
-- step 1 create a table for pageviews with products url in the time period
create temporary table products_pageviews
select website_session_id,
 pageview_url,
website_pageview_id,
created_at,
case when created_at < '2013-01-06' then  'A.pre_product_2'
	when created_at >= '2013-01-06' then  'B.post_product_2'
end as time_period
from website_pageviews
where created_at < '2013-04-06'
and created_at > '2012-10-06'
and pageview_url = '/products';

-- drop table min_pageview_for_products;
-- select * from products_pageviews;
create temporary table min_pageview_for_products
select products_pageviews.time_period,
products_pageviews.website_session_id,
website_pageviews.pageview_url,
min(website_pageviews.website_pageview_id) as min_pageview_id
from products_pageviews
left join website_pageviews
on website_pageviews.website_session_id = products_pageviews.website_session_id
and website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
group by 1,2;

select * from min_pageview_for_products;


-- final results
select time_period,
count(distinct website_session_id) as total_sessions,
count(distinct case when pageview_url is not null then website_session_id else null end ) as w_next_pg,
count(distinct case when pageview_url is not null then website_session_id else null end )/count(distinct website_session_id) as pct__w_next_pg,
count(distinct case when pageview_url = '/the-original-mr-fuzzy' then website_session_id else null end) as product_1,
count(distinct case when pageview_url = '/the-original-mr-fuzzy' then website_session_id else null end)/count(distinct website_session_id) as pct_product_1,
count(distinct case when pageview_url = '/the-forever-love-bear' then website_session_id else null end) as product_2,
count(distinct case when pageview_url = '/the-forever-love-bear' then website_session_id else null end)/count(distinct website_session_id) as pct_product_2
from min_pageview_for_products
group by 1;

