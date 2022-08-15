-- THIS FILE WILL DEF NEED SOME WORK --

{{
    config(
        enabled = true if var('user_properties', false) else false,
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

        {% for user_prop in var('user_properties', []) %},

        {{ unnest_by_key('user_properties', user_prop.user_property_name, user_prop.value_type) }}
        -- CHANGE TO MY MACRO --
        {{
            ga4.unnest_key(
                'user_properties',
                user_prop.user_property_name,
                user_prop.value_type
            )
        }}

        {% endfor %}
    FROM
        events_from_valid_users

),

-- Create 1 CTE per user property.
{% for user_prop in var('user_properties', []) %}

non_null_{{ user_prop.user_property_name }} AS (

    SELECT
        user_key,
        event_timestamp,
        {{ user_prop.user_property_name }}
    FROM
        unnest_user_properties
    WHERE
        {{ user_prop.user_property_name }} IS NOT NULL

),

last_value_{{ user_prop.user_property_name }} AS (

    SELECT
        user_key,
        {{ get_last('user_key', '{{ user_prop.user_property_name }}') }} AS {{ user_prop.user_property_name }}
    FROM
        non_null_{{ user_prop.user_property_name }}

),

last_value_{{ user_prop.user_property_name }}_grouped AS (

    SELECT
        user_key,
        {{ user_prop.user_property_name }}
    FROM
        last_value_{{ user_prop.user_property_name }}
    GROUP BY
        1,
        2

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

        {% for user_prop in var('user_properties', []) %},

        last_value_{{ user_prop.user_property_name }}_grouped.{{ user_prop.user_property_name }}

        {% endfor %}
    FROM
        user_keys

        {% for user_prop in var('user_properties', []) %}

        LEFT JOIN last_value_{{ user_prop.user_property_name }}_grouped USING (user_key)

        {% endfor %}

)

SELECT DISTINCT * FROM join_properties