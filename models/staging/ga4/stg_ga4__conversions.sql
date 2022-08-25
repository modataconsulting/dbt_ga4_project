-- TESTING THE MODEL HERE --

WITH base AS (

    SELECT
        *
    FROM
        {{ ref('stg_ga4__events') }}

),

add_conversion_events AS (

    SELECT
        event_key,
        
        {% for conversion_event in var('conversion_events') -%}

        IF(event_name = '{{ conversion_event }}', 1, 0) AS is_{{ conversion_event }},
    
        {{- "," if not loop.last }}
        {% endfor %}
    FROM
        base

)

SELECT * FROM add_conversion_events
