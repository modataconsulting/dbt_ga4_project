-- INCLUDE DESCRIPTION HERE TO DESCRIBE FILE --

WITH first_last_event AS (

    SELECT
        client_id,
        {{ get_position('FIRST', 'client_id', 'event_key') }} AS first_event,
        {{ get_position('LAST', 'client_id', 'event_key') }} AS last_event,
    FROM
        {{ ref('stg_ga4__events') }}

),

-- MAYBE JUST MOVE DISTINCT TO ABOVE CTE AND GET RID OF THIS ONE? --
events_by_client_id AS (

    SELECT DISTINCT
        client_id,
        first_event,
        last_event
    FROM
        first_last_event

),

events_joined AS (

    SELECT
        events_by_client_id.*,
        events_first.geo AS first_geo,
        events_first.device AS first_device,
        events_first.traffic_source AS first_traffic_source,
        events_last.geo AS last_geo,
        events_last.device AS last_device,
        events_last.traffic_source AS last_traffic_source
    FROM
        events_by_client_id
        LEFT JOIN {{ ref('stg_ga4__events') }} events_first
            ON events_by_client_id.first_event = events_first.event_key
        LEFT JOIN {{ ref('stg_ga4__events') }} events_last
            ON events_by_client_id.last_event = events_last.event_key

)

SELECT * FROM events_joined