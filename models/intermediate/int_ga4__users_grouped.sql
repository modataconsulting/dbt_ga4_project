WITH user_scoped_events AS (

    SELECT
        *,

        {{ get_first('user_key', 'event_date') }}               AS first_seen_date,
        {{ get_first('user_key', 'event_timestamp') }}          AS first_seen_timestamp,
        {{ get_first('user_key', 'traffic_source') }}           AS first_traffic_source,
        {{ get_first('user_key', 'geo') }}                      AS first_geo,
        {{ get_first('user_key', 'device') }}                   AS first_device,
        {{ get_last('user_key', 'event_date') }}                AS last_seen_date,
        {{ get_last('user_key', 'event_date') }}                AS last_seen_timestamp,
        {{ get_last('user_key', 'traffic_source') }}            AS last_traffic_source,
        {{ get_last('user_key', 'geo') }}                       AS last_geo,
        {{ get_last('user_key', 'device') }}                    AS last_device
    FROM
        {{ ref('ga4__events') }} -- MAY BE ABLE TO/SHOULD USE 'ga4_sessions' INSTEAD --

),


users AS (

    SELECT
        -- Dimensions --
        user_key,
        MIN(first_seen_date)                AS first_seen_date,
        MIN(first_seen_timestamp)           AS first_seen_timestamp,        
        ANY_VALUE(first_traffic_source)     AS first_traffic_source,
        ANY_VALUE(first_geo)                AS first_geo,
        ANY_VALUE(first_device)             AS first_device,
        MAX(last_seen_date)                 AS last_seen_date,
        MAX(last_seen_timestamp)            AS last_seen_timestamp,
        ANY_VALUE(last_traffic_source)      AS last_traffic_source,
        ANY_VALUE(last_geo)                 AS last_geo,
        ANY_VALUE(last_device)              AS last_device,

        -- Metrics --
        COUNT(DISTINCT session_key) AS lifetime_sessions,
        -- AS lifetime_engaged_sessions,
        {{ get_total_duration('engagement_time_msec') }} AS lifetime_session_duration,
        -- AS avg_session_duration, -- NEED TO FIX THIS --
        COUNTIF(event_name = 'page_view') as page_views,
        -- SUM(MAX(session_event_number)) AS lifetime_event_count,
        -- ROUND(SAFE_DIVIDE(SUM(MAX(session_event_number)), SUM(is_page_view)), 2) AS avg_events_per_page,
        SUM(event_value) AS lifetime_value
        -- ...[ADD COUNT OF EACH CONVERSION EVENT]... --
    FROM
        user_scoped_events
    GROUP BY
        1

)

SELECT * FROM users