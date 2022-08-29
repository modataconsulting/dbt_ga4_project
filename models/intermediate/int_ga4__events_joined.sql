WITH events AS (

    SELECT
        *
    EXCEPT (
        event_params,
        user_properties, 
        traffic_source
    )
    FROM
        {{ ref('stg_ga4__events') }}

),

excluded_columns AS (

    SELECT
        *
    {% if var('excluded_columns', none) is not none -%}
    EXCEPT (
        {% for excluded_column in var('excluded_columns') -%}

        {{ excluded_column }}
    
        {{- "," if not loop.last }}
        {% endfor %}
    )
    {%- endif %}
    FROM
        events

),

join_event_params AS (

    SELECT
        *
    FROM
        excluded_columns
        LEFT JOIN {{ ref('stg_ga4__event_params') }} USING (event_key)

),

join_user_props AS (

    SELECT
        *
    FROM
        join_event_params
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
