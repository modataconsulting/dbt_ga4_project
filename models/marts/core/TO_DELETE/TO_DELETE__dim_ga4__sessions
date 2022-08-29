-- Dimension table for sessions based on the session_start event.

WITH session_start_dims AS (

    SELECT
        session_key,
        traffic_source,
        ga_session_number,
        page_location AS landing_page,
        page_hostname AS landing_page_hostname,
        geo,
        device,
        ROW_NUMBER() OVER (
            PARTITION BY session_key
            ORDER BY
                session_event_number ASC
        ) AS row_num
    FROM
        {{ ref('stg_ga4__event_session_start') }}

),

-- Arbitrarily pull the first session_start event to remove duplicates.
remove_duplicates AS (

    SELECT
        *
    FROM
        session_start_dims
    WHERE
        row_num = 1

),

join_traffic_source AS (

    SELECT
        remove_duplicates.*,
        session_source AS source,
        session_medium AS medium,
        session_default_channel_grouping AS default_channel_grouping
    FROM
        remove_duplicates
        LEFT JOIN {{ ref('stg_ga4__sessions_traffic_sources') }} USING (session_key)

)

SELECT * FROM join_traffic_source