-- INCLUDE DESCRIPTION HERE TO DESCRIBE FILE --

WITH session_start_with_params AS (

    SELECT
        *,
        {{ unnest_by_key('event_params', 'entrances', 'int') }},
        {{ unnest_by_key('event_params', 'value', 'float') }}

        {%- if var('session_start_custom_parameters', 'none') != 'none' -%}

        {{ stage_custom_parameters(var('session_start_custom_parameters')) }}

        {%- endif %}
    FROM
        {{ ref('stg_ga4__events') }}
    WHERE
        event_name = 'session_start'

)

SELECT * FROM session_start_with_params