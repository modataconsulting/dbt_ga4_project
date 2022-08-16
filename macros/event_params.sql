-- #1: CREATE TABLE OF UNIQUE `event_params` BY `key` AND THEIR RESPECTIVE `value_type`. --
{% macro get_event_param_value_types() %}
    SELECT
        key,
        CASE
            WHEN COUNTIF(value.string_value IS NOT NULL) > 0 THEN 'string'
            WHEN COUNTIF(value.int_value IS NOT NULL) > 0 THEN 'int'
            WHEN COUNTIF(value.float_value IS NOT NULL) > 0 THEN 'float'
            WHEN COUNTIF(value.double_value IS NOT NULL) > 0 THEN 'double'
            ELSE NULL
        END AS value_type
    FROM
    {{ ref('stg_ga4__events') }},
    UNNEST(event_params)
    GROUP BY
    1
{% endmacro %}

-- OR ALL IN ONE, LIKE THIS?? --
{%- macro new_unnest_by_key(column_to_unnest, key_to_extract) -%}

        {%- set get_event_param_value_type -%}

            SELECT
                CASE
                    WHEN COUNTIF(value.string_value IS NOT NULL) > 0 THEN 'string'
                    WHEN COUNTIF(value.int_value IS NOT NULL) > 0 THEN 'int'
                    WHEN COUNTIF(value.float_value IS NOT NULL) > 0 THEN 'float'
                    WHEN COUNTIF(value.double_value IS NOT NULL) > 0 THEN 'double'
                    ELSE NULL
                END AS value_type
            FROM
            {{ ref('stg_ga4__events') }},
            UNNEST(event_params)
            WHERE
                key = '{{ key_to_extract }}'
            GROUP BY
            key

        {%- endset -%}

        {%- set event_param_value_type = run_query(get_event_param_value_type) -%}

        {%- if execute -%}
        {%- set value_type = event_param_value_type.columns[0].values() -%}
        {%- else -%}
        {%- set value_type = [] -%}
        {%- endif -%}

        (
        SELECT
            value.{{ value_type }}_value
        FROM
            UNNEST({{ column_to_unnest }})
        WHERE
            key = '{{ key_to_extract }}'
        ) AS {{ key_to_extract }}

{%- endmacro -%}
