wk 1:
1) 130 users
2) 7.680851 orders/hr
3) 3.891803278689 days from order to delivery
4) 1 order: 25 users 2 orders: 28 users 3+ users: 71 users
5) 16.327586 sessions/hr


wk 2:
1) repeat user rate = 0.798387 or ~80%
2) all of the following would have a positive indicator of repeat purchases if the number is high and the inverse if the number is low:
    - number of page hits per user
    - length of activity
3) my product mart was formulated with events & products being joined at the intermediate layer then adding additional business transformations & logic at the fact layer.  I did this in mind of what I think should be exposed in BI applications to other analysts vs. what dimensionality I want to keep further upstream.
4) testing: I checked for null values both at the stg layer and int/fact layer.  no issues in calculating page views by product, though I do see what appear to be placeholder item names.  not sure how I would test for that other than filtering it out. 
5) snapshots: 
the following products had w/w inventory changes:
- Monstera
- Pothos
- Philodendron
- String of pearls

wk 3:
1) conversion rate = 0.624567
2) PRODUCT_NAME	CONVERSION_RATE
String of pearls	0.6
Arrow Head	0.546875
Pilea Peperomioides	0.466667
Philodendron	0.47619
Rubber Plant	0.5
Jade Plant	0.478261
Orchid	0.453333
Cactus	0.545455
Birds Nest Fern	0.4125
Snake Plant	0.39726
Spider Plant	0.474576
Pothos	0.328125
Peace Lily	0.402985
Boston Fern	0.412698
Dragon Tree	0.467742
Bird of Paradise	0.45
Devil's Ivy	0.488889
Money Tree	0.464286
Ponytail Palm	0.394366
Ficus	0.426471
Majesty Palm	0.478261
Pink Anthurium	0.418919
Calathea Makoyana	0.509434
Monstera	0.510204
Alocasia Polly	0.388889
Bamboo	0.521739
Aloe Vera	0.492308
Angel Wings Begonia	0.387097
Fiddle Leaf Fig	0.474576
ZZ Plant	0.523077

-----------------

here's my SQL for all of the answers, I don't know if we're supposed to include it 👛 🕗 🚨

select
    count(*) as user_count    
from
    dev_db.dbt_epond94gmailcom.stg_users;

    
select
    min(created_at) as min_date,
    max(created_at) as max_date,
    timestampdiff(hour, min(created_at), max(created_at)),
    count(order_id) as order_count,
    count(order_id) / timestampdiff(hour, min(created_at), max(created_at)) as orders_per_hour
from
    dev_db.dbt_epond94gmailcom.stg_orders;


with
ttd
as
(
select
    created_at,
    delivered_at,
    timestampdiff(hour, created_at, delivered_at)/24 as time_to_delivery
from
    dev_db.dbt_epond94gmailcom.stg_orders
)

select
    avg(time_to_delivery) as avg_time_to_delivery
from
    ttd;

with
order_count
as
(
select
    user_id,
    count(order_id) as order_count
from
    dev_db.dbt_epond94gmailcom.stg_orders
group by
    user_id
),
rank
as
(
select
    user_id,
    case
        when order_count = 1 then '1'
        when order_count = 2 then '2'
        when order_count >= 3 then '3+'
    end as order_rank
from
    order_count
)

select
    count(*) as users,
    order_rank
from
    rank
group by
    order_rank
;

with
sessions_per_hr
as
(
select
    date_trunc(hour,created_at) as hour,
    count(distinct session_id) as distinct_sessions
from
    dev_db.dbt_epond94gmailcom.stg_events
group by
    date_trunc(hour,created_at)
)

select
    sum(distinct_sessions) / count(hour)
from
    sessions_per_hr
;

with 
orders_by_user
as
(
select
    u.user_id,
    count(distinct o.order_id) as number_of_orders
from
    orders o
left join
    users u on u.user_id = o.user_id
group by
    u.user_id
)

select
    count(case when number_of_orders > 1 then 1 end) / count(*) as repeat_rate
from
    orders_by_user obu;

SELECT
    ep.product_id,
    SUM(CASE WHEN ep.event_type = 'checkout' THEN ep.event_count ELSE 0 END) AS num_checkouts,
    SUM(CASE WHEN ep.event_type = 'page_view' THEN ep.event_count ELSE 0 END) AS total_page_views,
    CASE
        WHEN SUM(CASE WHEN ep.event_type = 'page_view' THEN ep.event_count ELSE 0 END) = 0 THEN NULL
        ELSE SUM(CASE WHEN ep.event_type = 'checkout' THEN ep.event_count ELSE 0 END) / SUM(CASE WHEN ep.event_type = 'page_view' THEN ep.event_count ELSE 0 END)
    END AS conversion_rate
FROM
    {{ ref('int_events_product') }} ep
GROUP BY
    ep.product_id;

SELECT
    ep.product_id,
    p.name as product_name,
    SUM(CASE WHEN ep.event_type = 'checkout' THEN ep.event_count ELSE 0 END) AS num_checkouts,
    SUM(CASE WHEN ep.event_type = 'page_view' THEN ep.event_count ELSE 0 END) AS total_page_views,
    CASE
        WHEN SUM(CASE WHEN ep.event_type = 'page_view' THEN ep.event_count ELSE 0 END) = 0 THEN NULL
        ELSE SUM(CASE WHEN ep.event_type = 'checkout' THEN ep.event_count ELSE 0 END) / SUM(CASE WHEN ep.event_type = 'page_view' THEN ep.event_count ELSE 0 END)
    END AS conversion_rate
FROM
    {{ ref('int_events_product') }} ep
left join
    {{ ref('stg_products') }} p on p.product_id = ep.product_id
GROUP BY
    ep.product_id,
    p.name;