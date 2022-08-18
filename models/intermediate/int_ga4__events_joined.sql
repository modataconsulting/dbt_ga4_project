WITH events AS (

    SELECT
        *
    EXCEPT (
        privacy_info,
        user_properties, 
        user_ltv, 
        device, 
        geo, 
        app_info,  
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
        LEFT JOIN {{ ref('TESTING__stg_ga4__event_params') }} USING (event_key)

),

join_items AS (

    SELECT
        *
    FROM
        join_event_params
        LEFT JOIN {{ ref('TESTING__stg_ga4__items') }} USING (event_key)

),

join_user_props AS (

    SELECT
        *
    FROM
        join_items
        LEFT JOIN {{ ref('TESTING__stg_ga4__user_props') }} USING (event_key)

)

SELECT * FROM join_user_props