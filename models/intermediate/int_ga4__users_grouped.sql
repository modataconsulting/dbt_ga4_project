WITH user_scoped_events AS (

    SELECT
        *,

        {{ get_first('user_key', 'event_date') }}               AS first_seen_date,
        {{ get_first('user_key', 'event_timestamp') }}          AS first_seen_timestamp,
        {{ get_first('user_key', 'traffic_source') }}           AS first_traffic_source,
        {{ get_first('user_key', 'geo') }}                      AS first_geo,
        {{ get_first('user_key', 'device') }}                   AS first_device,
        {{ get_last('user_key', 'event_date') }}                AS last_seen_date,
        {{ get_last('user_key', 'event_timestamp') }}           AS last_seen_timestamp,
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
        MAX(last_seen_date)                 AS last_seen_date,
        MAX(last_seen_timestamp)            AS last_seen_timestamp,
        STRUCT(
            ANY_VALUE(first_traffic_source) AS traffic_source,
            ANY_VALUE(first_geo)            AS geo,
            ANY_VALUE(first_device)         AS device
        ) AS user_first,
        STRUCT(
            ANY_VALUE(last_traffic_source)  AS traffic_source,
            ANY_VALUE(last_geo)             AS geo,
            ANY_VALUE(last_device)          AS device
        ) AS user_last,

        -- Metrics --
        COUNT(DISTINCT session_key) AS lifetime_sessions,
        -- AS lifetime_engaged_sessions,
        {{ get_total_duration('engagement_time_msec') }} AS lifetime_session_duration,
        -- AS avg_session_duration, -- NEED TO FIX THIS --
        -- SUM(MAX(session_event_number)) AS lifetime_event_count,
        -- ROUND(SAFE_DIVIDE(SUM(MAX(session_event_number)), SUM(is_page_view)), 2) AS avg_events_per_page,
        SUM(event_value) AS lifetime_value,

        STRUCT(
            {% for engagement_event in get_engagement_events() -%}

            COUNTIF(event_name = '{{ engagement_event['event_name'] }}') AS {{ engagement_event['event_name'] }}s
        
            {{- "," if not loop.last }}
            {% endfor %}
        ) AS engagement_events,        
        STRUCT(
            {% for conversion_event in var('conversion_events') -%}

            COUNTIF(event_name = '{{ conversion_event }}') AS {{ conversion_event }}s
        
            {{- "," if not loop.last }}
            {% endfor %}
        ) AS conversion_events
    FROM
        user_scoped_events
    GROUP BY
        1

)

SELECT * FROM users