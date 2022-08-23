WITH user_scoped_events AS (

    SELECT
        *,

        {{ get_first('user_key', 'event_date') }}               AS first_seen_date,
        {{ get_first('user_key', 'event_timestamp') }}          AS first_seen_timestamp,
        {{ get_first('user_key', 'default_channel_grouping') }} AS first_default_channel_grouping,
        {{ get_first('user_key', 'source') }}                   AS first_source,
        {{ get_first('user_key', 'medium') }}                   AS first_medium,
        {{ get_first('user_key', 'campaign_name') }}            AS first_campaign_name,
        {{ get_first('user_key', 'country') }}                  AS first_country,
        {{ get_first('user_key', 'city') }}                     AS first_city,
        {{ get_first('user_key', 'category') }}                 AS first_category,
        {{ get_first('user_key', 'operating_system') }}         AS first_operating_system,
        {{ get_last('user_key', 'event_date') }}                AS last_seen_date,
        {{ get_last('user_key', 'event_date') }}                AS last_seen_timestamp,
        {{ get_last('user_key', 'default_channel_grouping') }}  AS last_default_channel_grouping,
        {{ get_last('user_key', 'source') }}                    AS last_source,
        {{ get_last('user_key', 'medium') }}                    AS last_medium,
        {{ get_last('user_key', 'campaign_name') }}             AS last_campaign_name,
        {{ get_last('user_key', 'country') }}                   AS last_country,
        {{ get_last('user_key', 'city') }}                      AS last_city,
        {{ get_last('user_key', 'category') }}                  AS last_category,
        {{ get_last('user_key', 'operating_system') }}          AS last_operating_system
    FROM
        {{ ref('ga4__events') }} -- MAY BE ABLE TO USE 'ga4_sessions' INSTEAD --

),


users AS (

    SELECT
        -- Dimensions --
        user_key,
        MIN(first_seen_date)                AS first_seen_date,
        MIN(first_seen_timestamp)           AS first_seen_timestamp,
        MIN(first_default_channel_grouping) AS first_default_channel_grouping,
        MIN(first_source)                   AS first_source,
        MIN(first_medium)                   AS first_medium,
        MIN(first_campaign_name)            AS first_campaign_name,
        MIN(first_country)                  AS first_country,
        MIN(first_city)                     AS first_city,
        MIN(first_category)                 AS first_category,
        MIN(first_operating_system)         AS first_operating_system,
        MAX(last_seen_date)                 AS last_seen_date,
        MAX(last_seen_timestamp)            AS last_seen_timestamp,
        MAX(last_default_channel_grouping)  AS last_default_channel_grouping,
        MAX(last_source)                    AS last_source,
        MAX(last_medium)                    AS last_medium,
        MAX(last_campaign_name)             AS last_campaign_name,
        MAX(last_country)                   AS last_country,
        MAX(last_city)                      AS last_city,
        MAX(last_category)                  AS last_category,
        MAX(last_operating_system)          AS last_operating_system,

        -- Metrics --
        COUNT(DISTINCT session_key) AS lifetime_sessions,
        -- AS lifetime_engaged_sessions,
        CAST(CAST(ROUND(SUM(engagement_time_msec / 1000)) AS STRING) AS TIME FORMAT 'SSSSS') AS lifetime_engagemenet_duration,
        SUM(is_page_view) AS page_views,
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