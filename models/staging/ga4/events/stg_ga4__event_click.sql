-- reference here: https://support.google.com/analytics/answer/9216061?hl=en 
 
WITH click_with_params AS (

    SELECT
        *,
        {{ unnest_by_key('event_params', 'entrances', 'int') }},
        {{ unnest_by_key('event_params', 'outbound') }},
        {{ unnest_by_key('event_params', 'link_classes') }},
        {{ unnest_by_key('event_params', 'link_domain') }},
        {{ unnest_by_key('event_params', 'link_url') }},
        {{ unnest_by_key('event_params', 'click_element') }},
        {{ unnest_by_key('event_params', 'link_id') }},
        {{ unnest_by_key('event_params', 'click_region') }},
        {{ unnest_by_key('event_params', 'click_tag_name') }},
        {{ unnest_by_key('event_params', 'click_url') }},
        {{ unnest_by_key('event_params', 'file_name') }}
        
        {% if var('click_custom_parameters', 'none') != 'none' %}
        
        {{ stage_custom_parameters(var('click_custom_parameters')) }}
        
        {% endif %}
    FROM
        {{ ref('stg_ga4__events') }}
    WHERE
        event_name = 'click'

)

SELECT * FROM click_with_params