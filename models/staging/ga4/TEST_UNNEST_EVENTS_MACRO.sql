{{
  config(
    materialized="table"
  )
}}

-- TESTING THE MACRO HERE, VERY MUCH STILL A WORK IN PROGESS --
{%- set event_names = dbt_utils.get_column_values(
    table = ref('stg_ga4__events'),
    column = 'event_name'
) | unique %}

WITH base AS (

    SELECT
        *
    FROM
        {{ ref('stg_ga4__events') }}

),

{%- for event_name in event_names %}

{{ event_name }}_with_params AS (

    {%- set get_event_params -%}

        SELECT DISTINCT
            key
        FROM   
            {{ ref('stg_ga4__events') }},
            UNNEST(event_params)
        WHERE
            event_name = '{{ event_name }}'
            AND key NOT IN UNNEST({{ var('excluded_event_params') }})
            AND (
                value.string_value IS NOT NULL
                OR value.int_value IS NOT NULL
                OR value.float_value IS NOT NULL
                OR value.double_value IS NOT NULL
            )

    {%- endset %}

    {%- set event_params_results = run_query(get_event_params) -%}

    {%- if execute -%}
    {%- set event_params = event_params_results.columns[0].values() -%}
    {%- else -%}
    {%- set event_params = [] -%}
    {%- endif %}

    SELECT
        *,

        {%- for event_param in event_params -%}

        {{ new_unnest_by_key('event_params', event_param) }}
        
        {{- "," if not loop.last }}
        {%- endfor %}
    FROM
        {{ ref('stg_ga4__events') }}
    WHERE
        event_name = '{{ event_name }}'

),

{%- if loop.last %}

last_event AS (

    SELECT
        *
    FROM
        {{ event_name }}__with_params

)

{%- endif -%}
{% endfor %}

SELECT * FROM last_event
