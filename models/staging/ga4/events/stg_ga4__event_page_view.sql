-- INCLUDE DESCRIPTION HERE TO DESCRIBE FILE --

WITH page_view_with_params AS (

    SELECT
        *,
        {{ unnest_by_key('event_params', 'entrances', 'int') }},
        {{ unnest_by_key('event_params', 'value', 'float') }}

        {%- if var('page_view_custom_parameters', 'none') != 'none' %}

        {{ stage_custom_parameters(var('page_view_custom_parameters')) }}

        {%- endif %}
    FROM
        {{ ref('stg_ga4__events') }}
    WHERE
        event_name = 'page_view'

),

first_last_pageview_session AS (

    SELECT
        *
    FROM
        {{ ref('stg_ga4__sessions_first_last_pageviews') }}

),

-- Determine the session's first pageview pageview based on event_timestamp. This is redundant with the 'entrances' int value, but calculated in the warehouse so a bit more transparent in how it operates.
first_pageview_joined AS (

    SELECT
        page_view_with_params.*, -- IS THE TABLE NAME WITH . NOTATION NECESSARY IN A JOIN? --
        IF(first_last_pageview_session.first_page_view_event_key IS NULL, FALSE, TRUE) AS is_entrance
    FROM
        page_view_with_params
        LEFT JOIN first_last_pageview_session
            ON page_view_with_params.event_key = first_last_pageview_session.first_page_view_event_key

),

last_pageview_joined AS (

    SELECT
        first_pageview_joined.*, -- IS THE TABLE NAME WITH . NOTATION NECESSARY IN A JOIN? --
        IF(first_last_pageview_session.last_page_view_event_key IS NULL, FALSE, TRUE) AS is_exit
    FROM
        first_pageview_joined
        LEFT JOIN first_last_pageview_session
            ON first_pageview_joined.event_key = first_last_pageview_session.last_page_view_event_key

)

SELECT * FROM last_pageview_joined