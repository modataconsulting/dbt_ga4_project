WITH page_views AS (

    SELECT
        event_date AS date,
        EXTRACT(HOUR FROM(SELECT event_timestamp)) AS hour,
        page_location,
        page_title,

        -- MOVE THIS UPSTREAM TO MAKE ALL KEYS AT ONCE --
        TO_BASE64(
            MD5(
                CONCAT(
                    CAST(event_date AS STRING),
                    CAST(EXTRACT(HOUR FROM(SELECT event_timestamp)) AS STRING),
                    page_location
                )
            )
        ) AS page_key,
        SUM(is_page_view) AS page_views,
        COUNT(DISTINCT user_key) AS users,
        SUM(is_new_user) AS new_users,
        SUM(is_entrance) AS entrances, -- CURRENTLY OVERCOUNTING, NEED TO EXCLUDE 'bounces' ESSENTIALL --
        ROUND(SAFE_DIVIDE(SUM(is_entrance), COUNT(DISTINCT session_key)), 2) AS entrance_rate, -- CURRENTLY OVERCOUNTING, NEED TO EXCLUDE 'bounces' ESSENTIALL --
        SUM(is_exit) AS exits, -- CURRENTLY OVERCOUNTING, NEED TO EXCLUDE 'bounces' ESSENTIALL --
        ROUND(SAFE_DIVIDE(SUM(is_exit), COUNT(DISTINCT session_key)), 2) AS exit_rate, -- CURRENTLY OVERCOUNTING, NEED TO EXCLUDE 'bounces' ESSENTIALL --
        CAST(CAST(ROUND(SUM(engagement_time_msec / 1000)) AS STRING) AS TIME FORMAT 'SSSSS') AS total_engagement_duration,
        CAST(CAST(ROUND(AVG(engagement_time_msec / 1000)) AS STRING) AS TIME FORMAT 'SSSSS') AS avg_engagement_duration
    FROM
        {{ ref('int_ga4__events_joined') }} -- REPLACE WITH 'ga4__events' INSTEAD WHEN FINISHED --
    GROUP BY
        1,
        2,
        3,
        4,
        5

)

SELECT * FROM page_views