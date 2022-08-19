-- Fact table for sessions, joined on 'session_key' & 'user_key'.

WITH session_metrics AS (

    SELECT
        session_key,
        user_key,
        MIN(event_date) AS session_start_date,
        MIN(event_timestamp) AS session_start_timestamp,
        COUNTIF(event_name = 'page_view') AS page_views,
        SUM(event_value) AS sum_event_value,
        IFNULL(MAX(session_engaged), 0) AS session_engaged
    FROM
        {{ ref('stg_ga4__events') }}
    GROUP BY
        1,
        2

)

SELECT * FROM session_metrics