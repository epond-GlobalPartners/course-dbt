{% macro grant_select_permissions(schema, table, role) %}
  GRANT SELECT ON {{ ref(schema, table) }} TO ROLE {{ role }};
{% endmacro %}