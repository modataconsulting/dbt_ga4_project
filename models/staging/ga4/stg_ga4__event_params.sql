WITH base AS (

    SELECT
        *
    FROM
        {{ ref('stg_ga4__events') }}

),

unnest_custom_event_params AS (

    SELECT
        event_key,

        {% for event_param in get_event_params() -%}

        {{ unnest_by_key('event_params', event_param['event_param_key'], event_param['event_param_value']) }}
    
        {{- "," if not loop.last }}
        {% endfor %}
    FROM
        base

)

SELECT * FROM unnest_custom_event_params
