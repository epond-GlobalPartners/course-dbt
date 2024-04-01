SELECT
    oi.order_id,
    oi.quantity as order_quantity,

    pd.product_id,
    pd.name as product_name,
    pd.price as product_price
FROM
    {{ ref('stg_order_items') }} oi 
left join 
    {{ ref('stg_products') }} pd on oi.product_id = pd.product_id