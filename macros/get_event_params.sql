{%- macro get_event_params() -%}

    {% set query %}

    SELECT
        event_params.key AS event_param_key,
        CASE
            WHEN event_params.value.string_value IS NOT NULL THEN 'string'
            WHEN event_params.value.int_value IS NOT NULL THEN 'int'
            WHEN event_params.value.float_value IS NOT NULL THEN 'float'
            WHEN event_params.value.double_value IS NOT NULL THEN 'double'
            ELSE NULL
        END AS event_param_value
    FROM
        {{ ref('stg_ga4__events') }},
        UNNEST(event_params) AS event_params
    WHERE
        event_params.key NOT IN UNNEST({{ var('excluded_event_params') }})
        AND (
            event_params.value.string_value IS NOT NULL
            OR event_params.value.int_value IS NOT NULL
            OR event_params.value.float_value IS NOT NULL
            OR event_params.value.double_value IS NOT NULL
        )
    GROUP BY
        event_param_key,
        event_param_value
    ORDER BY
        event_param_key

    {% endset %}

    {% set query_results = run_query(query) %}

    {% if execute %}
        {%- set results = query_results -%}
    {%- else -%}
        {%- set results = [] -%}
    {%- endif -%}

    {{ return(results) }}

{%- endmacro %}