-- INCLUDE DESCRIPTION HERE TO DESCRIBE FILE --

WITH scroll_with_params AS (

    SELECT
        *,
        {{ unnest_by_key('event_params', 'percent_scrolled', 'int') }}

        {% if var('scroll_custom_parameters', 'none') != 'none' %}

        {{ stage_custom_parameters(var('scroll_custom_parameters')) }}

        {% endif %}
    FROM
        {{ ref('stg_ga4__events') }}
    WHERE
        event_name = 'scroll'

)

SELECT * FROM scroll_with_params