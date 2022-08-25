WITH events AS (

    SELECT
        *
    EXCEPT (
        event_params,
        privacy_info,
        user_properties, 
        user_ltv, 
        device, 
        geo, 
        app_info,
        traffic_source,
        ecommerce, 
        items
    )
    FROM
        {{ ref('stg_ga4__events') }}

),

join_event_params AS (

    SELECT
        *
    FROM
        events
        LEFT JOIN {{ ref('stg_ga4__event_params') }} USING (event_key)

),

join_items AS (

    SELECT
        *
    FROM
        join_event_params
        LEFT JOIN {{ ref('stg_ga4__items') }} USING (event_key)

),

join_user_props AS (

    SELECT
        *
    FROM
        join_items
        LEFT JOIN {{ ref('stg_ga4__user_props') }} USING (event_key)

),

join_traffic_sources AS (

    SELECT
        *
    FROM
        join_user_props
        LEFT JOIN {{ ref('stg_ga4__traffic_sources') }} USING (event_key)

),

join_conversions AS (

    SELECT
        *
    FROM
        join_traffic_sources
        LEFT JOIN {{ ref('stg_ga4__conversions') }} USING (event_key)

)

SELECT * FROM join_conversions