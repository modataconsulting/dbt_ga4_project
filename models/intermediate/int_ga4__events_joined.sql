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

add_first_last_params AS (

    SELECT
        *,

        IF({{ get_last('session_key', 'event_key') }} = event_key, 1, 0) AS is_exit
    FROM
        events

),

join_event_params AS (

    SELECT
        *
    FROM
        add_first_last_params
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

)

SELECT * FROM join_traffic_sources