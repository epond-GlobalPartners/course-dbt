with page_view_sessions as (
    select distinct session_id
    from {{ ref('stg_events') }}
    where event_type = 'page_view'
),
add_to_cart_sessions as (
    select distinct session_id
    from {{ ref('stg_events') }}
    where event_type = 'add_to_cart'
),
checkout_sessions as (
    select distinct session_id
    from {{ ref('stg_events') }} 
    where event_type = 'checkout'
)

    select
        'page_view' as stage,
        count(*) as session_count
    from page_view_sessions
    union all
    select
        'add_to_cart' as stage,
        count(*) as session_count
    from add_to_cart_sessions
    union all
    select
        'checkout' as stage,
        count(*) as session_count
    from checkout_sessions
