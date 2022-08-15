-- INCLUDE DESCRIPTION HERE TO DESCRIBE FILE --

WITH page_view_with_params AS (

    SELECT
        *,
        {{ unnest_by_key('event_params', 'entrances', 'int') }},
        {{ unnest_by_key('event_params', 'value', 'float') }},

        LAG(page_location, 1) OVER (
            PARTITION BY (session_key)
            ORDER BY
                event_timestamp asc
        ) AS session_previous_page,
        
        {%- for i in range(4) %}
        
        CASE
            WHEN SPLIT(SPLIT(page_location, '/')[SAFE_ORDINAL({{ i+4 }})], '?')[SAFE_ORDINAL(1)] = '' THEN NULL
            ELSE CONCAT(
                '/',
                SPLIT(SPLIT(page_location, '/')[SAFE_ORDINAL({{ i+4 }})], '?')[SAFE_ORDINAL(1)]
            )
        END AS pagepath_level_{{ i+1 }},
        
        {%- endfor%}
        
        {%- if var('page_view_custom_parameters', 'none') != 'none' %}
        
        {{ ga4.stage_custom_parameters(var('page_view_custom_parameters')) }}
        
        {%- endif %}
    FROM
        {{ ref('stg_ga4__events') }}
    WHERE
        event_name = 'page_view'

),

last_pageview_joined AS (

    SELECT
        page_view_with_params.*,
        IF(first_last_pageview_session.last_page_view_event_key IS NULL, NULL, 1) AS exits
    FROM
        page_view_with_params
        LEFT JOIN {{ ref('stg_ga4__sessions_first_last_pageviews') }} first_last_pageview_session
            ON page_view_with_params.event_key = first_last_pageview_session.last_page_view_event_key

)

SELECT * FROM last_pageview_joined