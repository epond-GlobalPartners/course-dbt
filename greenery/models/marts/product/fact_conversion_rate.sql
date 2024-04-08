SELECT
    COUNT(DISTINCT CASE WHEN e.event_type = 'checkout' THEN e.session_id END) / COUNT(DISTINCT e.session_id) AS conversion_rate
FROM
    {{ ref('stg_events') }} e
LEFT JOIN
    {{ ref('stg_orders') }} o ON e.order_id = o.order_id
LEFT JOIN
    {{ ref('stg_order_items') }} oi ON o.order_id = oi.order_id