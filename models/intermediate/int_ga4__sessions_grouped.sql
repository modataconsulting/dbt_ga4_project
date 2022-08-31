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
        ANY_VALUE(traffic_source)     AS traffic_source,
        ANY_VALUE(geo)                AS geo,
        ANY_VALUE(device)             AS device,
        -- [TODO] AS user_props,
        -- [TODO] AS event_params,

        -- Facts/Metrics --
        {{ get_total_duration('engagement_time_msec') }} AS session_duration,
        MAX(session_event_number) AS session_event_count,
        ROUND(SAFE_DIVIDE(MAX(session_event_number), COUNTIF(event_name = 'page_view')), 2) AS avg_events_per_page,
        MAX(event_value) AS session_value,

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
        session_scoped_events
    GROUP BY
        1,
        2

)

SELECT * FROM sessions