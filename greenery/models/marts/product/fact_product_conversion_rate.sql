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
    p.name