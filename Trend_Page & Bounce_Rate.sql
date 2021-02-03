-- trend page analysis
-- drop table session_minpage_count;
create temporary table session_minpage_count
select ws.website_session_id,
min(wp.website_pageview_id) as min_page_view_id,
count(wp.website_pageview_id) as count_pageviews
from website_sessions ws
left join website_pageviews wp
using (website_session_id)
where ws.created_at > '2012-06-01' and
ws.created_at < '2012-08-31'
and ws.utm_source ='gsearch'
and ws.utm_campaign ='nonbrand'
group by 1;

-- select * from session_minpage_count;
create temporary table session_with_count_created_at
select s.website_session_id,
s.min_page_view_id,
s.count_pageviews,
w.pageview_url,
w.created_at
from session_minpage_count s
left join website_pageviews w
using (website_session_id);

select * from session_with_count_created_at;

select 
-- yearweek(created_at) as week_year,
min(date(created_at)) as week_start_date,
-- count(distinct website_session_id) as total_sessions,
-- count(distinct case when count_pageviews=1 then website_session_id else null end) as bounced_sessions,
count( distinct case when count_pageviews=1 then website_session_id else null end)/count( distinct website_session_id) *100 as bounced_rate,
count( distinct case when pageview_url='/home' then website_session_id else null end) as home_sessions,
count( distinct case when pageview_url='/lander-1' then website_session_id else null end) as lander_sessions
from session_with_count_created_at
group by yearweek(created_at);




-- time frame is 19th June to 28th July 2012
create temporary table first_test_pageviews
select w.website_session_id,
min(wp.website_pageview_id) as first_pageview
from website_pageviews wp
inner join website_sessions w
using (website_session_id)
where wp.created_at between '2012-06-19' and '2012-07-28'
and utm_source = 'gsearch'
and utm_campaign= 'nonbrand'
group by 1
order by 2;

create temporary table non_brand_landing_pageview
select ft.website_session_id,
w.pageview_url as landing_page
from first_test_pageviews ft
left join website_pageviews w
on ft.first_pageview = w.website_pageview_id
where w.pageview_url in ('/home','/lander-1');

-- count no. of pageviews and filter the sessions that were only viewed once
create temporary table bounced_sessions
select n.website_session_id,
n.landing_page,
count(w.website_pageview_id) as n_pages_viewed
from non_brand_landing_pageview n
left join website_pageviews w
using (website_session_id)
group by 1,2
having n_pages_viewed = 1;

-- 
select 
n.landing_page,
count(b.website_session_id) as bounced_sessions,
count(n.website_session_id) as total_sessions,
count(b.website_session_id)/count(n.website_session_id) * 100 as bounce_rate
from non_brand_landing_pageview n
left join bounced_sessions b
using (website_session_id)
group by 1
order by 4 desc;
