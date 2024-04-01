SELECT
    first_name,
    last_name,
    email,
    phone_number,
    address,
    zipcode,
    state,
    country
FROM
    {{ ref('int_users') }}