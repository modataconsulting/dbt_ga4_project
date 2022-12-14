-- Need to rework this, doesn't really allow for further aggregation by end-users (i.e. there are duplicates of page_views, users, sessions, etc.). --

WITH page_views AS (

    SELECT
        -- Dimensions --
        TO_BASE64(
            MD5(
                CONCAT(
                    CAST(event_date AS STRING),
                    CAST(EXTRACT(HOUR FROM(SELECT event_timestamp)) AS STRING),
                    page_location
                )
            )
        ) AS page_key, -- Surrogate key for pages.
        event_date                                 AS page_date,
        EXTRACT(HOUR FROM(SELECT event_timestamp)) AS page_hour,
        page_path,
        page_title,
        
        -- Facts/Metrics --
        COUNTIF(event_name = 'page_view')                                                     AS page_views,
        COUNT(DISTINCT user_key)                                                              AS users,
        -- ROUND(SAFE_DIVIDE(COUNTIF(event_name = 'page_view'), COUNT(DISTINCT user_key)), 2)    AS pageviews_per_user,
        SUM(is_new_user)                                                                      AS new_users,
        COUNT(DISTINCT session_key)                                                           AS sessions,
        -- ROUND(SAFE_DIVIDE(COUNTIF(event_name = 'page_view'), COUNT(DISTINCT session_key)), 2) AS pageviews_per_session,
        SUM(is_entrance)                                                                      AS entrances,
        -- ROUND(SAFE_DIVIDE(SUM(is_entrance), COUNT(DISTINCT session_key)), 2)                  AS entrance_rate,
        SUM(is_exit)                                                                          AS exits,
        -- ROUND(SAFE_DIVIDE(SUM(is_exit), COUNT(DISTINCT session_key)), 2)                      AS exit_rate,
        {{ get_total_duration('engagement_time_msec') }}                                      AS total_engagement_duration,

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
        {{ ref('ga4__events') }}
    WHERE
        page_location IS NOT NULL
    GROUP BY
        1,
        2,
        3,
        4,
        5

)

SELECT * FROM page_views