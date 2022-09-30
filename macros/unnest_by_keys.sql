-- Unnests a single key's value from an array

{%- macro unnest_by_key(column_to_unnest, key_to_extract, value_type = "string") -%}

        (
            SELECT
                value.{{ value_type }}_value
            FROM
                UNNEST({{ column_to_unnest }})
            WHERE
                key = '{{ key_to_extract }}'
        ) AS {{ key_to_extract }}

{%- endmacro -%}


{%- macro unnest_by_key_alt(column_to_unnest, key_to_extract, value_type = "string") -%}

        (
            SELECT
                value.{{ value_type }}_value
            FROM
                UNNEST({{ column_to_unnest }})
            WHERE
                key = '{{ key_to_extract }}'
        )

{%- endmacro -%}

-- MACRO FOR HANDLING `query_params` --
{%- macro unnest_by_key_2(column_to_unnest, key_to_extract) -%}

        (
            SELECT
                value
            FROM
                UNNEST({{ column_to_unnest }})
            WHERE
                key = '{{ key_to_extract }}'
            LIMIT 1
        ) AS {{ key_to_extract }}

{%- endmacro -%}




-- REFACTORING MACRO -- [OLD]
{%- macro unnest_by_key2(column_to_unnest, key_to_extract) -%}
        
        {% set value_types = ["string", "int", "float", "double"] %}

        (
        SELECT
            {%- if value_type == "string" %}
            value.string_value AS value_type
            {% else %}
            COALESCE(value.int_value, value.float_value, value.double_value) AS value_type
            {%- endif %}
        FROM
            UNNEST({{ column_to_unnest }})
        WHERE
            key = '{{ key_to_extract }}'
        ) AS {{ key_to_extract }}

{%- endmacro -%}
