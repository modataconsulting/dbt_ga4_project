WITH unnest_default_event_params AS (

    SELECT
        event_params,
        event_key,

        {{ unnest_by_key('event_params', 'ga_session_number',  'int') }},
        IF(({{ unnest_by_key_alt('event_params', 'session_engaged') }}) = '1', 1, 0) AS is_engaged_session,
        
        -- LET'S JUST MAKE A MACRO FOR THIS DURATION METRIC AND DO IT DOWNSTREAM INSTEAD?
        CAST(CAST(ROUND({{ unnest_by_key_alt('event_params', 'engagement_time_msec', 'int') }} / 1000) AS STRING) AS TIME FORMAT 'SSSSS') AS engagement_duration,
      
        {{ unnest_by_key('event_params', 'engagement_time_msec', 'int') }},
        IF(({{ unnest_by_key_alt('event_params', 'entrances', 'int') }}) = 1, 1, 0) AS is_entrance,
        IF({{ get_last('session_key', 'event_key') }} = event_key, 1, 0) AS is_exit,
        
        -- SEEING SOME DISCREPANCIES BETWEEN THIS AND MANUALLY PULLING FROM EVENT PARAMS --
        -- USING 'event_' PREFIX IN MEANTIME TO DIFFERENTIATE --
        {{ unnest_by_key_alt('event_params', 'source') }} AS event_source, -- PULL FROM THE DEDICATED 'traffic_source' RECORD FIELD INSTEAD? --
        {{ unnest_by_key_alt('event_params', 'medium') }} AS event_medium, -- PULL FROM THE DEDICATED 'traffic_source' RECORD FIELD INSTEAD? --
        {{ unnest_by_key_alt('event_params', 'campaign') }} AS event_campaign, -- PULL FROM THE DEDICATED 'traffic_source' RECORD FIELD INSTEAD? --
        {{ unnest_by_key_alt('event_params', 'term') }} AS term,
        IF(event_name = 'first_visit', 1, 0) AS is_new_user
    FROM
        {{ ref('stg_ga4__events') }}

),

unnest_custom_event_params AS (

    SELECT
        * EXCEPT (event_params),

        {% if get_event_params() | length > 0 -%}
        STRUCT(
            {% for event_param in get_event_params() -%}

            {{ unnest_by_key('event_params', event_param['event_param_key'], event_param['event_param_value']) }}
        
            {{- "," if not loop.last }}
            {% endfor %}
        ) AS event_params
        {%- endif %}
    FROM
        unnest_default_event_params

)

SELECT * FROM unnest_custom_event_params
