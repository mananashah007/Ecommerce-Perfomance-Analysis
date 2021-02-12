-- cross sell product analysis
-- step 1: /cart page sessions and pageview ids
create temporary table sessions_cart_page
select website_pageviews.website_pageview_id,
website_pageviews.website_session_id,
case when created_at < '2013-09-25' then 'A.pre_cross_sell' 
when created_at >= '2013-09-25' then 'B.post_cross_sell' 
else null
end as time_period
from website_pageviews
where created_at between '2013-08-25' and '2013-10-25'
and pageview_url = '/cart';

select * from sessions_cart_page;
-- step 2 find the website pageview id of the cart sessions that clicked the next page
create temporary table session_w_nxt_page
select sessions_cart_page.website_session_id,
sessions_cart_page.time_period,
min(website_pageviews.website_pageview_id) as next_pageview
from sessions_cart_page
left join website_pageviews
on sessions_cart_page.website_session_id = website_pageviews.website_session_id
and sessions_cart_page.website_pageview_id < website_pageviews.website_pageview_id
group by 1,2
having min(website_pageviews.website_pageview_id) is not null;

-- step 3 find orders which were placed from all these sessions
create temporary table orders_w_sessions
select time_period,
session_w_nxt_page.website_session_id,
orders.order_id,
orders.items_purchased,
orders.price_usd
from session_w_nxt_page
inner join orders
using (website_session_id);


-- step 4 agg results after joining original table with the next 2 tables created
select time_period,
count(distinct website_session_id) as cart_sessions,
sum(clicked_to_next_page) as clickthroughs,
sum(clicked_to_next_page)/count(distinct website_session_id) as cart_ctr,
sum(placed_order) as orders,
sum(items_purchased) as items,
sum(items_purchased)/sum(placed_order) as products_per_order,
sum(price_usd)/sum(placed_order) as aov,
sum(price_usd)/count(distinct website_session_id) as revenue_per_session
from (
select sessions_cart_page.time_period,
sessions_cart_page.website_session_id,
case when session_w_nxt_page.next_pageview is null then 0 else 1 end as clicked_to_next_page,
case when orders_w_sessions.order_id is null then 0 else 1 end as placed_order,
orders_w_sessions.items_purchased,
orders_w_sessions.price_usd
from sessions_cart_page
left join  session_w_nxt_page
using (website_session_id)
left join orders_w_sessions
using (website_session_id)
) as full_data
group by 1;