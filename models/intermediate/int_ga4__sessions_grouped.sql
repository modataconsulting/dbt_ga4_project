WITH session_scoped_events AS (

    SELECT
        *,

        {{ get_first('session_key', 'page_path') }} AS landing_page -- WILL MOVE UPSTREAM --
    FROM
        {{ ref('ga4__events') }}

),


sessions AS (

    SELECT
        -- Dimensions --
        user_key,
        session_key,
        MIN(event_date)               AS session_date,
        MIN(event_timestamp)          AS session_timestamp,
        MAX(is_new_user)              AS is_new_user,
        MAX(ga_session_number)        AS ga_session_number,
        MAX(is_engaged_session)       AS is_engaged_session,
        MAX(landing_page)             AS landing_page,
        MAX(default_channel_grouping) AS default_channel_grouping,
        MAX(source)                   AS source,
        MAX(medium)                   AS medium,
        MAX(campaign)                 AS campaign,
        MAX(country)                  AS country,
        MAX(city)                     AS city,
        MAX(device_category)          AS device_category,
        MAX(operating_system)         AS operating_system,
        -- [TODO] AS traffic_source,
        -- [TODO] AS geo,
        -- [TODO] AS device,
        -- [TODO] AS user_props,
        -- [TODO] AS event_params,

        -- Facts/Metrics --
        {{ get_total_duration('engagement_time_msec') }} AS session_duration,
        COUNTIF(event_name = 'page_view') as page_views,
        MAX(session_event_number) AS session_event_count,
        ROUND(SAFE_DIVIDE(MAX(session_event_number), COUNTIF(event_name = 'page_view')), 2) AS avg_events_per_page,
        MAX(event_value) AS session_value
        -- ...[ADD COUNT OF EACH CONVERSION EVENT]... --
    FROM
        session_scoped_events
    GROUP BY
        1,
        2

)

SELECT * FROM sessions