SELECT
    ep.event_date,
    ep.event_count as page_views,
    pd.name as product_name
FROM
    {{ ref('int_events_product') }} ep
left join
    {{ ref('stg_products') }} pd on ep.product_id = pd.product_id
where
    ep.event_type = 'page_view'