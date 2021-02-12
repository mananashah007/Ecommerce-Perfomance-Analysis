create temporary table sessions_users
select new_sessions.user_id,
new_sessions.website_session_id,
website_sessions.website_session_id as repeat_sessions
from
(
select website_session_id,
user_id
from website_sessions
where created_at between '2014-01-01' and '2014-11-01'
and is_repeat_session = 0
) as new_sessions
left join website_sessions
on website_sessions.user_id = new_sessions.user_id
and is_repeat_session = 1
and created_at between '2014=01-01' and '2014-11-01';

select * from sessions_users;

select repeat_sessions,
count(user_id) as users
from (
select user_id,
count(distinct website_session_id) as new_sessions,
count(distinct repeat_sessions) as repeat_sessions
from sessions_users
group by 1
) as x
group by 1
order by 2 desc;

-- average, min and max days between the first and second sessions
-- step 1 : get the new sessions
create temporary table session_w_created_at
select
new_sessions.user_id,
new_sessions.website_session_id as old_sessions,
website_sessions.website_session_id,
new_sessions.created_at as first_created_at,
website_sessions.created_at as sec_created_at
from
(
select
user_id,
website_session_id,
created_at
from website_sessions
where created_at between '2014-01-01' and '2014-11-03'
and is_repeat_session = 0
) as new_sessions
left join website_sessions
on website_sessions.user_id = new_sessions.user_id
and website_sessions.is_repeat_session = 1
where website_sessions.created_at between '2014-01-01' and '2014-11-03';

select * from session_w_created_at;

select 
min(datediff(second_created_at,first_created_at)) as minimum_days,
avg(datediff(second_created_at,first_created_at)) as avg_days,
max(datediff(second_created_at,first_created_at)) as max_days
from 
(
select user_id,
old_sessions,
first_created_at,
min(website_session_id) as second_session,
min(sec_created_at) as second_created_at
from session_w_created_at
where website_session_id is not null
group by 1,2,3
) as x;

-- analysing repeat sessions channel group wise
select distinct http_referer from website_sessions;

select 
case when utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then 'organic search' 
 when utm_campaign = 'brand' then 'paid_brand'
 when utm_campaign = 'nonbrand' then 'paid_nonbrand'
 when utm_source is null and http_referer is null then 'direct_type_in'
 when utm_source = 'socialbook' then 'paid_social'
 else 'Check logic'
 end as channel_group,
 count(distinct case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
 count(distinct case when is_repeat_session = 1 then website_session_id else null end) as repeat_sessions
 from website_sessions
 where created_at between '2014-01-01' and '2014-11-05'
 group by 1
 order by 2,3 desc;
 
 -- comparison between new and repeat sessions for the conversion rate and revenue per sessions
 select 
 website_sessions.is_repeat_session,
 count(distinct website_sessions.website_session_id) as sessions,
 count(distinct orders.order_id) as orders,
 count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conv_rate,
 sum(orders.price_usd)/count(distinct website_session_id) as revenue_per_session
 from website_sessions
 left join orders
 using (website_session_id)
 where website_sessions.created_at between '2014-01-01' and '2014-11-08'
 group by 1;