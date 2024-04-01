SELECT
    date(e.created_at) as event_date,
    count(*) as event_count,
    e.product_id,
    e.event_type
FROM
    {{ ref('stg_events') }} e 
group by
    date(e.created_at),
    e.product_id,
    e.event_type