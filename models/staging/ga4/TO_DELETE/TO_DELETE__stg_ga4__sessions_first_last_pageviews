-- INCLUDE DESCRIPTION HERE TO DESCRIBE FILE --

WITH page_views_first_last AS (

    SELECT
        session_key,
        {{ get_first('session_key', 'event_key') }} AS first_page_view_event_key,
        {{ get_last('session_key', 'event_key') }} AS last_page_view_event_key
    FROM
        {{ ref('stg_ga4__events') }}
    WHERE
        event_name = 'page_view'
),

page_views_by_session_key AS (

    SELECT DISTINCT
        session_key,
        first_page_view_event_key,
        last_page_view_event_key
    FROM
        page_views_first_last

)

SELECT * FROM page_views_by_session_key