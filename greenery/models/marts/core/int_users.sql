SELECT
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.created_at,
    u.updated_at,
    a.address,
    a.zipcode,
    a.state,
    a.country
FROM
    {{ ref('stg_users') }} u
left join
    {{ ref('stg_addresses') }} a on a.address_id = u.address_id