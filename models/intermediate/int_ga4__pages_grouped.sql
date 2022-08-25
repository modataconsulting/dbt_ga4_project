WITH page_views AS (

    SELECT
        event_date AS date,
        EXTRACT(HOUR FROM(SELECT event_timestamp)) AS hour,
        page_path,
        page_title,
        page_key,
        COUNTIF(event_name = 'page_view') as page_views, -- LETS DO IT THIS WAY TO ELIMATE CREATING EXTRA COLUMNS FOR EACH 'is_[event_name]' --
        COUNT(DISTINCT user_key) AS users,
        ROUND(SAFE_DIVIDE(COUNTIF(event_name = 'page_view'), COUNT(DISTINCT user_key)), 2) AS pageviews_per_user,
        SUM(is_new_user) AS new_users,
        COUNT(DISTINCT session_key) AS sessions,
        ROUND(SAFE_DIVIDE(COUNTIF(event_name = 'page_view'), COUNT(DISTINCT session_key)), 2) AS pageviews_per_session,
        SUM(is_entrance) AS entrances,
        ROUND(SAFE_DIVIDE(SUM(is_entrance), COUNT(DISTINCT session_key)), 2) AS entrance_rate,
        SUM(is_exit) AS exits,
        ROUND(SAFE_DIVIDE(SUM(is_exit), COUNT(DISTINCT session_key)), 2) AS exit_rate,
        {{ get_total_duration('engagement_time_msec') }} AS total_engagement_duration,
        {{ get_avg_duration('engagement_time_msec') }} AS avg_engagement_duration
    FROM
        {{ ref('ga4__events') }}
    GROUP BY
        1,
        2,
        3,
        4,
        5

)

SELECT * FROM page_views