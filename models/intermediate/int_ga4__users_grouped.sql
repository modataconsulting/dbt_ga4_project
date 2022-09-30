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
        COUNT(DISTINCT session_key)                                           AS lifetime_sessions,
        COUNT(DISTINCT CASE WHEN is_engaged_session = 1 THEN session_key END) AS lifetime_engaged_sessions,
        ROUND(
            (COUNT(DISTINCT CASE WHEN is_engaged_session = 1 THEN session_key END) /
            COUNT(DISTINCT session_key)) * 100, 2
        )                                                                     AS lifetime_engagement_rate,
        {{ get_total_duration('engagement_time_msec') }}                      AS lifetime_session_duration,
        {{ get_avg_duration('engagement_time_msec') }}                        AS avg_session_duration,
        COUNT(event_name)                                                     AS lifetime_events,
        ROUND(COUNT(event_name) / COUNT(DISTINCT session_key), 2)             AS avg_events_per_session,
        -- ROUND(COUNT(event_name) / COUNTIF(event_name = 'page_view'), 2)       AS avg_events_per_page,
        SUM(event_value)                                                      AS lifetime_value,

        -- Funnel Score Test [TODO] --

        -- Struct of all events, except those set in the `var('excluded__events')` --
        STRUCT(
            {% for event in get_events() -%}

            COUNTIF(event_name = '{{ event['event_name'] }}') AS {{ event['event_name'] }}
        
            {{- "," if not loop.last }}
            {% endfor %}
        ) AS events,

        -- Struct of the events set in the `var('consideration_events')` --
        STRUCT(
            {% for consideration_event in var('consideration_events') -%}

            COUNTIF(event_name = '{{ consideration_event }}') AS {{ consideration_event }}
        
            {{- "," if not loop.last }}
            {% endfor %}

        ) AS consideration_events,

        -- Struct of the events set in the `var('conversion_events')` --
        STRUCT(
            {% for conversion_event in var('conversion_events') -%}

            COUNTIF(event_name = '{{ conversion_event }}') AS {{ conversion_event }}
        
            {{- "," if not loop.last }}
            {% endfor %}

        ) AS conversion_events
    FROM
        user_scoped_events
    GROUP BY
        1

)

SELECT * FROM users