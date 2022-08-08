-- User dimensions: first geo, first device, last geo, last device, first seen, last seen

WITH users AS (

    SELECT
        client_id,
        MIN(event_timestamp) AS first_seen_timestamp,
        MIN(event_date_dt) AS first_seen_dt,
        MAX(event_timestamp) AS last_seen_timestamp,
        MAX(event_date_dt) AS last_seen_dt,
        COUNT(DISTINCT session_key) AS num_sessions,
        SUM(is_page_view) AS num_page_views,
        SUM(is_purchase) AS num_purchases
    FROM
        {{ ref('stg_ga4__events') }}
    GROUP BY
        1

),

include_first_last_events AS (

    SELECT
        users.*,
        first_last_events.first_geo,
        first_last_events.first_device,
        first_last_events.first_traffic_source,
        first_last_events.last_geo,
        first_last_events.last_device,
        first_last_events.last_traffic_source,
    FROM
        users
        LEFT JOIN {{ ref('stg_ga4__users_first_last_events') }} AS first_last_events
            ON users.client_id = first_last_events.client_id

),

include_first_last_page_views AS (

    SELECT
        include_first_last_events.*,
        first_last_page_views.first_page_location,
        first_last_page_views.first_page_hostname,
        first_last_page_views.first_page_referrer,
        first_last_page_views.last_page_location,
        first_last_page_views.last_page_hostname,
        first_last_page_views.last_page_referrer
    FROM
        include_first_last_events
        LEFT JOIN {{ ref('stg_ga4__users_first_last_pageviews') }} AS first_last_page_views
            ON include_first_last_events.client_id = first_last_page_views.client_id

)

SELECT * FROM include_first_last_page_views

{% if var('user_properties', false) %}

-- If custom user properties have been assigned as variables, join them on the client ID.
LEFT JOIN {{ ref('stg_ga4__user_properties') }} USING (client_id)

{% endif %}