-- INCLUDE DESCRIPTION HERE TO DESCRIBE FILE --

WITH first_last_event AS (

    SELECT
        user_key,
        {{ get_first('user_key', 'event_key') }} AS first_event,
        {{ get_last('user_key', 'event_key') }} AS last_event,
    FROM
        {{ ref('stg_ga4__events') }}
    WHERE user_key IS NOT NULL --remove users with privacy settings enabled

),

-- MAYBE JUST MOVE DISTINCT TO ABOVE CTE AND GET RID OF THIS ONE? --
events_by_user_key AS (

    SELECT DISTINCT
        user_key,
        first_event,
        last_event
    FROM
        first_last_event

),

events_joined AS (

    SELECT
        events_by_user_key.*,
        events_first.geo AS first_geo,
        events_first.device AS first_device,
        events_first.traffic_source AS first_traffic_source,
        events_last.geo AS last_geo,
        events_last.device AS last_device,
        events_last.traffic_source AS last_traffic_source
    FROM
        events_by_user_key
        LEFT JOIN {{ ref('stg_ga4__events') }} events_first
            ON events_by_user_key.first_event = events_first.event_key
        LEFT JOIN {{ ref('stg_ga4__events') }} events_last
            ON events_by_user_key.last_event = events_last.event_key

)

SELECT * FROM events_joined