-- Unnests a single key's value from an array

{%- macro unnest_by_key(column_to_unnest, key_to_extract, value_type = "string", rename_column = "default") %}
        (SELECT
            value.{{ value_type }}_value
        FROM
            UNNEST({{ column_to_unnest }})
        WHERE
            key = '{{ key_to_extract }}'
        ) AS

        {%- if rename_column == "default" %}
            {{ key_to_extract }}
        {%- else %}
            {{ rename_column }}
        {%- endif -%}
{%- endmacro -%}