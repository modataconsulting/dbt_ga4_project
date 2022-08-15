-- INCLUDE DESCRIPTION HERE TO DESCRIBE FILE --

WITH page_views_first_last AS (

    SELECT
        user_key,

        -- MAYBE ADD THESE AS VARIABLES FURTHER UP STREAM AS THIS IS DUPLICATED ACCROSS AT LEAST 2 FILES --
        {{ get_first('user_key', 'event_key') }} AS first_page_view_event_key,
        {{ get_last('user_key', 'event_key') }} AS last_page_view_event_key,
    FROM
        {{ ref('stg_ga4__event_page_view') }}
    WHERE user_key IS NOT NULL --remove users with privacy settings enabled
),

page_views_by_user_key AS (

    SELECT DISTINCT
        user_key,
        first_page_view_event_key,
        last_page_view_event_key
    FROM
        page_views_first_last

),

page_views_joined AS (

    SELECT
        page_views_by_user_key.*,
        first_page_view.page_location AS first_page_location,
        first_page_view.page_hostname AS first_page_hostname,
        first_page_view.page_referrer AS first_page_referrer,
        last_page_view.page_location AS last_page_location,
        last_page_view.page_hostname AS last_page_hostname,
        last_page_view.page_referrer AS last_page_referrer
    FROM
        page_views_by_user_key
        LEFT JOIN {{ ref('stg_ga4__event_page_view') }} first_page_view
            ON page_views_by_user_key.first_page_view_event_key = first_page_view.event_key
        LEFT JOIN {{ ref('stg_ga4__event_page_view') }} last_page_view
            ON page_views_by_user_key.last_page_view_event_key = last_page_view.event_key

)

SELECT * FROM page_views_joined