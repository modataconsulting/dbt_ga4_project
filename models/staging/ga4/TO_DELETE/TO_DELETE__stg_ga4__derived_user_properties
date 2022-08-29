-- THIS FILE WILL DEF NEED SOME WORK --

{{
    config(
        enabled = true if var('derived_user_properties', false) else false,
        materialized = 'table'
    )
}}

-- Remove null user_keys (users with privacy enabled).
WITH events_from_valid_users AS (

    SELECT
        *
    FROM
        {{ ref('stg_ga4__events') }}
    WHERE
        user_key IS NOT NULL

),

unnest_user_properties AS (

    SELECT
        user_key,
        event_timestamp

        {% for user_prop in var('derived_user_properties', []) %}

        ,{{ ga4.unnest_key('event_params', user_prop.event_parameter, user_prop.value_type) }}

        {% endfor %}
    FROM
        events_from_valid_users

),

-- Create 1 CTE per user property that pulls only events with non-null values for that event parameters.
-- Find the most recent property for that user and join later.
{% for user_prop in var('derived_user_properties', []) %}

non_null_{{ user_prop.event_parameter }} AS (

    SELECT
        user_key,
        event_timestamp,
        {{ user_prop.event_parameter }}
    FROM
        unnest_user_properties
    WHERE
        {{ user_prop.event_parameter }} IS NOT NULL

),

last_value_{{ user_prop.event_parameter }} AS (

    SELECT
        user_key,
        {{ get_position('LAST', 'user_key', '{{ user_prop.event_parameter }}') }} AS {{ user_prop.user_property_name }}
    FROM
        non_null_{{ user_prop.event_parameter }}

),

last_value_{{ user_prop.event_parameter }}_grouped AS (

    SELECT
        user_key,
        {{ user_prop.user_property_name }}
    FROM
        last_value_{{ user_prop.event_parameter }}
    GROUP BY
        user_key,
        {{ user_prop.user_property_name }}

),

{% endfor %}

user_keys AS (
    SELECT DISTINCT
        user_key
    FROM
        events_from_valid_users

),

join_properties AS (

    SELECT
        user_key

        {% for user_prop in var('derived_user_properties', []) %},

        ,last_value_{{ user_prop.event_parameter }}_grouped.{{ user_prop.user_property_name }}

        {% endfor %}
    FROM
        user_keys

        {% for user_prop in var('derived_user_properties', []) %}

        LEFT JOIN last_value_{{ user_prop.event_parameter }}_grouped USING (user_key)

        {% endfor %}

)

SELECT DISTINCT * FROM join_properties