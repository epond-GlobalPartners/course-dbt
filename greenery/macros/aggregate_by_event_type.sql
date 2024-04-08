{% macro aggregate_by_event_type(stg_events, created_at, product_id) %}

{% set aggregated_table_name = 'aggregated_by_event_type_' ~ source_table %}

-- Define the SQL block for the macro
{% set sql %}
SELECT
    date({{ created_at }}) as event_date,
    {{ product_id }},
    SUM(CASE WHEN event_type = 'checkout' THEN event_count ELSE 0 END) AS num_checkouts,
    SUM(CASE WHEN event_type = 'page_view' THEN event_count ELSE 0 END) AS total_page_views
FROM
    {{ ref(stg_events) }}
GROUP BY
    date({{ created_at }}),
    {{ product_id }}
{% endset %}

{{ adapter.dispatch_sql(rendered_sql=sql, model_name=aggregated_table_name) }}

{% endmacro %}