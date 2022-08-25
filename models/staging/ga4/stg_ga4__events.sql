-- This staging model contains key creation and window functions. Keeping window functions outside of the base incremental model ensures that the incremental updates don't artificially limit the window partition sizes (ex: if a session spans 2 days, but only 1 day is in the incremental update)

WITH joined_base_events AS (

    SELECT
        *
    FROM
        {{ ref('base_ga4__events')}}
    {%- if var('include_intraday_events', false) -%}
    UNION ALL
    SELECT
        *
    FROM
        {{ref('base_ga4__events_intraday')}}
    {%- endif %}

),

unnest_required_event_params AS (

    SELECT       
        *,
        
        {{ unnest_by_key('event_params', 'ga_session_id', 'int') }}, -- NEED HERE --
        {{ unnest_by_key('event_params', 'page_location') }} -- NEED HERE --
    FROM
        joined_base_events

),

-- Add a unique key for the user that checks for user_id and then pseudo_user_id.
add_user_key AS (

    SELECT
        *,
        CASE
            WHEN user_id IS NOT NULL THEN TO_BASE64(MD5(user_id))
            WHEN user_pseudo_id IS NOT NULL THEN TO_BASE64(MD5(user_pseudo_id))
            ELSE NULL -- this case is reached when privacy settings are enabled
        END AS user_key
    FROM
        unnest_required_event_params

),

-- Add unique keys for sessions.
add_session_key AS (

    SELECT
        *,
        TO_BASE64(
            MD5(
                CONCAT(
                    stream_id,
                    CAST(user_key AS STRING),
                    CAST(ga_session_id AS STRING)
                )
            )
        ) AS session_key -- Surrogate key to determine unique session across streams and users. Sessions do NOT reset after midnight in GA4.
    FROM
        add_user_key

),

-- ADD 'page_key' & 'page_number' HERE?? --
add_page_key AS (

    SELECT
        *,
        TO_BASE64(
            MD5(
                CONCAT(
                    CAST(event_date AS STRING),
                    CAST(EXTRACT(HOUR FROM(SELECT event_timestamp)) AS STRING),
                    page_location
                )
            )
        ) AS page_key -- Surrogate key for pages.
    FROM
        add_session_key

),

-- Add event numbers for each event.
add_event_number AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY session_key
            ORDER BY event_timestamp
        ) AS session_event_number -- Chronologically number each event within a session to help generate a unique event key.
    FROM
        add_page_key

),

-- Add unique keys for events.
add_event_key AS (

    SELECT
        *,
        TO_BASE64(
            MD5(
                CONCAT(
                    CAST(session_key AS STRING),
                    CAST(session_event_number AS STRING)
                )
            )
        ) AS event_key -- Surrogate key for unique events.
    FROM
        add_event_number

),

-- Add derived boolean params specificying the first & last events.
add_is_first_last_params AS (

    SELECT
        *,

        IF({{ get_first('session_key', 'event_key') }} = event_key, 1, 0) AS is_first_session_event,
        IF({{ get_last('session_key', 'event_key') }} = event_key, 1, 0) AS is_last_session_event,
        IF({{ get_first('user_key', 'event_key') }} = event_key, 1, 0) AS is_first_user_event,
        IF({{ get_last('user_key', 'event_key') }} = event_key, 1, 0) AS is_last_user_event,
    FROM
        add_event_key

),

-- TODO: UNNEST ALL OTHER DEFAULT/STATIC REPEATED FIELDS HERE --
---------------------------------------------------------

-- INCLUDE 'privacy_info' RECORD FIELD HERE? --

-- INCLUDE 'user_ltv' RECORD FIELD HERE? --

unnest_device AS (

    SELECT
        *,

        device.category                 AS device_category,
        device.mobile_brand_name        AS mobile_brand_name,
        device.mobile_model_name        AS mobile_model_name,
        device.mobile_marketing_name    AS mobile_marketing_name,
        device.mobile_os_hardware_model AS mobile_os_hardware_model,
        device.operating_system         AS operating_system,
        device.operating_system_version AS operating_system_version,
        device.vendor_id                AS vendor_id,
        device.advertising_id           AS advertising_id,
        device.language                 AS language,
        device.is_limited_ad_tracking   AS is_limited_ad_tracking,
        device.time_zone_offset_seconds AS time_zone_offset_seconds,
        device.web_info.browser         AS browser,
        device.web_info.browser_version AS browser_version
    FROM
        add_is_first_last_params

),

unnest_geo AS (

    SELECT
        *,

        geo.continent     AS continent,
        geo.sub_continent AS sub_continent,
        geo.country       AS country,
        geo.region        AS region,
        geo.city          AS city,
        geo.metro         AS metro
    FROM
        unnest_device

),

-- INCLUDE 'app_info' RECORD FIELD HERE? --

-- INCLUDE 'event_dimensions' RECORD FIELD HERE? --

-- INCLUDE 'eccommerce' RECORD FIELD HERE? --

---------------------------------------------------------

-- Remove specific query strings from page_location field.
remove_query_params AS (

    SELECT
        * EXCEPT (page_location),
        page_location AS original_page_location,
    
        -- If there are query parameters to exclude, exclude them using RegEx.
        {% if var('query_parameter_exclusions', none) is not none -%}

        {{ remove_query_parameters('page_location', var('query_parameter_exclusions')) }} AS page_location

        {% else -%}

        page_location

        {%- endif %}
    FROM
        unnest_geo

),

-- Enrich params by extracting 'page_hostname' and 'page_query_string' from the 'page_location' URL.
enrich_url_params AS (

    SELECT
        *,

        -- ADD 'page_path' HERE AS WELL --
        {{ unnest_by_key('event_params', 'page_title') }},
        {{ unnest_by_key('event_params', 'page_referrer') }},
        {{ extract_hostname_from_url('page_location') }}           AS page_hostname,
        {{ extract_query_string_from_url('page_location') }}       AS page_query_string,
        CONCAT('/', {{ dbt_utils.get_url_path('page_location') }}) AS page_path
    FROM
        remove_query_params

)

SELECT * FROM enrich_url_params
