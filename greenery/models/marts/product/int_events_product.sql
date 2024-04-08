SELECT
    date(e.created_at) as event_date,
    count(*) as event_count,
    coalesce(e.product_id,o.product_id) as product_id,
    e.event_type
FROM
    {{ ref('stg_events') }} e 
left join {{ ref('stg_order_items') }} o on o.order_id = e.order_id

group by
    date(e.created_at),
    coalesce(e.product_id,o.product_id),
    e.event_type