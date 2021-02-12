-- final project giving a data driven strory. growth and perfomance of the company
/* Q1 session and volume growth trended over quarter */
select
year(website_sessions.created_at) as yr,
quarter(website_sessions.created_at) as qtr,
count(distinct website_sessions.website_session_id) as sessions,
count(distinct orders.order_id) as orders
from website_sessions
left join orders
using (website_session_id)
group by 1,2;

/* Q2 session to order conv.rate and rev.per order and rev.per session */
select 
year(website_sessions.created_at) as yr,
quarter(website_sessions.created_at) as qtr,
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as session_order_conv_rate,
sum(orders.price_usd)/count(distinct orders.order_id) as rev_per_order,
sum(orders.price_usd)/count(distinct website_sessions.website_session_id) as rev_per_sessions
from website_sessions
left join orders
using (website_session_id)
group by 1,2;

-- Q3 quarterly view of various channels
select
year(website_sessions.created_at) as yr,
quarter(website_sessions.created_at) as qtr,
count(distinct case when utm_source is null and http_referer is null then orders.order_id else null end) as direct_type_in_orders,
count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then orders.order_id else null end) as gsearch_nonbrand,
count(distinct case when utm_source = 'bsearch' and utm_campaign = 'brand'then orders.order_id else null end) as bsearch_nonbrand,
count(distinct case when utm_campaign = 'brand' then orders.order_id else null end) as brand_orders,
count(distinct case when utm_source is null and http_referer is not null then orders.order_id else null end) as organic_search
from website_sessions
left join orders
using (website_session_id)
group by 1,2;

-- Q4 conversion rate about various channels similar to Q2 and Q3 and hence skipping this
-- Q5 monthly trending revenue and margin by product
select distinct primary_product_id from orders;
select 
year(created_at) as yr,
month(created_at) as mno,
sum(distinct case when orders.primary_product_id = 1 then orders.price_usd else null end) as prod1_rev,
sum(distinct case when orders.primary_product_id = 2 then orders.price_usd else null end) as prod2_rev,
sum(distinct case when orders.primary_product_id = 3 then orders.price_usd else null end) as prod3_rev,
sum(distinct case when orders.primary_product_id = 4 then orders.price_usd else null end) as prod4_rev,
sum(price_usd) as total_rev,
sum(price_usd - cogs_usd) as total_margin
from orders
group by 1,2;


-- Q6 monthly session to /products page and % of those sesssions clicking through another page and conversion from product to order
drop table product_sess_pageviews;
create temporary table product_sess_pageviews
select
created_at,
website_session_id,
website_pageview_id
from website_pageviews
where pageview_url = '/products';

select
year(product_sess_pageviews.created_at) as yr,
month(product_sess_pageviews.created_at) as mno,
count(distinct product_sess_pageviews.website_session_id) as product_page,
count(distinct website_pageviews.website_session_id) as clicked_next_page,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/count(distinct product_sess_pageviews.website_session_id) as prod_conv_rt
from product_sess_pageviews
left join website_pageviews
on product_sess_pageviews.website_session_id = website_pageviews.website_session_id
and product_sess_pageviews.website_pageview_id < website_pageviews.website_pageview_id
left join orders
on product_sess_pageviews.website_session_id = orders.website_session_id
group by 1,2;

-- 4th prodcut Dec 05,2014 sales from that day and trend to see cross sells
create temporary table primary_prod
select * from orders
where created_at > '2014-12-05';


select
primary_product_id,
count(distinct order_id) as orders,
count(distinct case when cross_sell_prod_id = 1 then order_id else null end) as x_sell_1,
count(distinct case when cross_sell_prod_id = 2 then order_id else null end) as x_sell_2,
count(distinct case when cross_sell_prod_id = 3 then order_id else null end) as x_sell_3,
count(distinct case when cross_sell_prod_id = 4 then order_id else null end) as x_sell_4
from (
select 
primary_prod.*,
order_items.product_id as cross_sell_prod_id
from primary_prod
left join order_items
on order_items.order_id = primary_prod.order_id
and is_primary_item = 0
) as x_sell
group by 1;