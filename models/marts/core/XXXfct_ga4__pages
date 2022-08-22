-- Fact table for pages, -- FINISH THIS LATER --

WITH page_view AS (

    SELECT
        event_date,
        EXTRACT(HOUR FROM(SELECT event_timestamp)) AS hour,
        page_location, -- Includes query string parameters not listed in query_parameter_exclusions variable.

        CONCAT(
            CAST(event_date AS string),
            CAST(EXTRACT(HOUR FROM(SELECT event_timestamp)) AS string), page_location
        ) AS page_key,

        page_title, -- Would like to move this to dim_ga4__pages but need to think how to handle page_title changing over time.
        COUNT(event_name) AS page_views,
        COUNT(DISTINCT user_key) AS users,
        SUM(IF(ga_session_number = 1, 1, 0)) AS new_users,
        SUM(entrances) AS entrances,
        SUM(exits) AS exits,
        SUM(engagement_time_msec) AS time_on_page
    FROM
        {{ ref('stg_ga4__event_page_view') }}
    GROUP BY
        1,
        2,
        3,
        4,
        5

),

scroll AS (

    SELECT
        event_date,
        EXTRACT(HOUR FROM(SELECT event_timestamp)) AS hour,
        page_location,
        page_title,
        COUNT(event_name) AS scroll_events
    FROM
        {{ ref('stg_ga4__event_scroll') }}
    GROUP BY
        1,
        2,
        3,
        4

),

{% if var('conversion_events', false) %}

join_conversions AS (

    SELECT
        *
    FROM
        page_view
        LEFT JOIN {{ ref('stg_ga4__page_conversions') }} USING (page_key)

),

final AS (

    SELECT
        join_conversions.* EXCEPT(page_key),
        IFNULL(scroll.scroll_events, 0) AS scroll_events
    FROM
        join_conversions
        LEFT JOIN scroll USING (event_date, hour, page_location, page_title)    

)

{% else %}

final AS (

    SELECT
        page_view.* EXCEPT(page_key),
        IFNULL(scroll.scroll_events, 0) AS scroll_events
    FROM
        page_view
        LEFT JOIN scroll USING (event_date, hour, page_location, page_title)

)

{% endif %}

SELECT * FROM final