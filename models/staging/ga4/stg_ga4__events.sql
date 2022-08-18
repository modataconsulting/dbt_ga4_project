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

-- I WANT EXPLICITLY LIST ALL BASE EVENTS INTIALLY FOR DOWNSTREAM INTERPREBILLITY AND UNNEST THEM TO BE WIDE & DENOMALIZED --
-- UNNEST ALL DEFAULT EVENTS --
unnest_default_event_params AS (

    SELECT
        *,
        
        -- DEFINATELY REFACTOR WITH MACRO TO BE DRY & DYNAMIC, USE IF/ELSE TO AUTO DETERMIN WHETHER IT WOULD BE STRING OR INT_VALUE -- 
        {{ unnest_by_key('event_params', 'ga_session_id', 'int') }},
        {{ unnest_by_key('event_params', 'ga_session_number',  'int') }},
        IF(({{ unnest_by_key_alt('event_params', 'session_engaged') }}) = '1', 1, 0) AS session_engaged,
        {{ unnest_by_key('event_params', 'engagement_time_msec', 'int') }},
        {{ unnest_by_key('event_params', 'page_location') }},
        {{ unnest_by_key('event_params', 'page_title') }},
        {{ unnest_by_key('event_params', 'page_referrer') }},
        {{ unnest_by_key('event_params', 'source') }}, -- PULL FROM THE DEDICATED 'traffic_source' RECORD FIELD INSTEAD? --
        {{ unnest_by_key('event_params', 'medium') }}, -- PULL FROM THE DEDICATED 'traffic_source' RECORD FIELD INSTEAD? --
        {{ unnest_by_key('event_params', 'campaign') }}, -- PULL FROM THE DEDICATED 'traffic_source' RECORD FIELD INSTEAD? --
        IF(event_name = 'page_view', 1, 0) AS is_page_view, -- ADD THIS TO A 'var("conversion_events")' FIELD TO DYNAMICALLY ADD THEM INSTEAD --
        IF(event_name = 'purchase', 1, 0) AS is_purchase -- ADD THIS TO A 'var("conversion_events")' FIELD TO DYNAMICALLY ADD THEM INSTEAD --
    FROM
        joined_base_events

),

-- TODO: UNNEST ALL OTHER DEFAULT REPEATED FIELDS HERE --
---------------------------------------------------------

-- INCLUDE 'privacy_info' RECORD FIELD HERE? --

-- REPEATED FIELD: INCLUDE 'user_properties' RECORD FIELD HERE? --

-- INCLUDE 'user_ltv' RECORD FIELD HERE? --

unnest_device AS (

    SELECT
        *,

        device.category                 AS category, -- RENAME TO 'device_cateogry' or 'device_type' INSTEAD? --
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
        unnest_default_event_params

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

-- SEEING SOME DISCREPANCIES BETWEEN THIS AND MANUALLY PULLING FROM EVENT PARAMS --
-- USING 'test_' PREFIX IN MEANTIME TO DIFFERENTIATE --
unnest_traffic_source AS (

    SELECT
        *,

        traffic_source.medium AS test_medium,
        traffic_source.name   AS test_name, -- CHANGE TO 'campaign_name' INSTEAD? --
        traffic_source.source AS test_source
    FROM
        unnest_geo

),

-- INCLUDE 'event_dimensions' RECORD FIELD HERE? --

-- INCLUDE 'eccommerce' RECORD FIELD HERE? --

-- REPEATED FIELD: INCLUDE 'items' RECORD FIELD HERE? --

---------------------------------------------------------

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
        unnest_traffic_source

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

-- Add event numbers for each event.
add_event_number AS (

    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY session_key) AS session_event_number -- Number each event within a session to help generate a unique event key.
    FROM
        add_session_key

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
        add_event_key

),

-- Enrich params by extracting 'page_hostname' and 'page_query_string' from the 'page_location' URL.
enrich_params AS (

    SELECT
        *,
        {{ extract_hostname_from_url('page_location') }} AS page_hostname,
        {{ extract_query_string_from_url('page_location') }} AS page_query_string,
    FROM
        remove_query_params

)

-- TODO: ADD THE DYNAMIC UNNESTING OF EVENT PARAMS HERE --

SELECT * FROM enrich_params