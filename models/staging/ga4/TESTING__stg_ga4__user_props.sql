-- TESTING THE MODEL HERE, LOL NO 'user_props' TO TEST AGAINST THO :/ --
-- I ALREADY KNOW I CAN REFACTOR THE 'get_event_params' MACRO TO TAKE ARG TO DISTINGUISH BETWEEN GETTING 'event_props' or 'user_props' --

WITH base AS (

    SELECT
        *
    FROM
        {{ ref('stg_ga4__events') }}

),

unnest_user_props AS (

    SELECT
        event_key,
        
        {% for user_prop in get_user_props() -%}

        {{ unnest_by_key('user_properties', user_prop['user_prop_key'], user_prop['user_prop_value']) }}
    
        {{- "," if not loop.last }}
        {% endfor %}
    FROM
        base

)

SELECT * FROM unnest_user_props
