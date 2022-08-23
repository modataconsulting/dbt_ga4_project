-- INCLUDE DESCRIPTION HERE TO DESCRIBE FILE --

WITH session_events AS (

    SELECT 
        session_key,
        event_timestamp,
        LOWER(source) AS source,
        medium,
        source_category
    FROM
        {{ ref('stg_ga4__events') }}
        LEFT JOIN {{ ref('ga4_source_categories') }} USING (source)

),

set_default_channel_grouping AS (

    SELECT
        *,
        {{ default_channel_grouping('source', 'medium', 'source_category') }} AS default_channel_grouping
    FROM
        session_events

),

session_source AS (

    SELECT
        session_key,
        {{ get_first('session_key', 'source') }} AS session_source,
        {{ get_first('session_key', 'medium') }} AS session_medium,
        {{ get_first('session_key', 'default_channel_grouping') }} AS session_default_channel_grouping
    FROM
        set_default_channel_grouping

)

SELECT DISTINCT * FROM session_source