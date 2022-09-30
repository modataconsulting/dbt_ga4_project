-- I ALREADY KNOW I CAN REFACTOR THE 'get_event_params' MACRO TO TAKE ARG TO DISTINGUISH BETWEEN GETTING 'event_props' or 'user_props' --

{%- macro get_user_props() -%}

    {% set query %}

    SELECT
        user_props.key AS user_prop_key,
        CASE
            WHEN user_props.value.string_value IS NOT NULL THEN 'string'
            WHEN user_props.value.int_value IS NOT NULL THEN 'int'
            WHEN user_props.value.float_value IS NOT NULL THEN 'float'
            WHEN user_props.value.double_value IS NOT NULL THEN 'double'
            ELSE NULL
        END AS user_prop_value
    FROM
        {{ ref('stg_ga4__events') }},
        UNNEST(user_properties) AS user_props
    WHERE
        user_props.key NOT IN UNNEST({{ var('excluded__user_props') }})
        AND (
            user_props.value.string_value IS NOT NULL
            OR user_props.value.int_value IS NOT NULL
            OR user_props.value.float_value IS NOT NULL
            OR user_props.value.double_value IS NOT NULL
        )
    GROUP BY
        user_prop_key,
        user_prop_value
    ORDER BY
        user_prop_key

    {% endset %}

    {% set query_results = run_query(query) %}

    {% if execute %}
        {%- set results = query_results -%}
    {%- else -%}
        {%- set results = [] -%}
    {%- endif -%}

    {{ return(results) }}

{%- endmacro %}