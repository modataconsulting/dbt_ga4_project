-- THIS MACRO WILL BE AN ATTEMPT AT CREATING A DYNAMIC MACRO TO AUTOMACIALLY CREATE A MODEL FOR ALL EVENTS AND UNNEST ALL OF THEIR EVENT_PARAMS IN ONE COMMAND --
-- THIS WILL HELP SETUP/CONFIGUARTION BE ALMOST INSTANT, WHERE EVERY EVENT_NAME IN 'stg_ga4_events' WILL BE AUTOMATICALLY DETECTED AND CREATE SUBSEQUENT MODELS FOR THEM --
-- IDEA, SIMPLY SET THIS MACRO TO RUN ON-START AND THEN IT SHOULD BE ABLE TO CREATE THESE AS ACTUAL MODELS --

-- NEED TO ACTUALLY CREATE A MODEL PER ITERATION AND NOT ALL BE IN ONE FILE, OR SHOULD WE CENTRALIZE IT TO ONE FILE? --
{% macro unnest_events(event_names) %}

    -- ITERATE THROUGH ALL 'event_names' --
    {% for event_name in event_names %}

        WITH {{ event_name }}_with_params AS (

        {%- set get_event_params -%} -- GET ALL 'event_params' FOR EACH SPECIFIC 'event_name'

            SELECT DISTINCT
                key
            FROM   
                {{ ref('stg_ga4__events') }},
                UNNEST(event_params)
            WHERE
                event_name = '{{ event_name }}'

        {%- endset -%}

        {%- set event_params_results = run_query(get_event_params) -%}

        {%- if execute -%}
        {%- set event_params = event_params_results.columns[0].values() -%}
        {%- else -%}
        {%- set event_params = [] -%}
        {%- endif -%}


            SELECT
                *,

                -- ITERATE THROUGH ALL 'event_params' --
                {% for event_param in event_params if not none -%}

                {{ unnest_by_key('event_params', event_param) }}, -- IF USING THIS METHOD, WE WILL WANT TO SIMPLY PASS THE EVENT NAME --

                {%- endfor %}

                {% if var("{{ event_name }}_custom_parameters", "none") != "none" -%}

                {{ stage_custom_parameters(var("{{ event_name }}_custom_parameters")) }} -- STAGES CUSTOM VARIABLES AS WELL IF SET...CAN WE ALSO JUST DO THIS DYNAMICALLY? --

                {%- endif%}
            FROM
                {{ ref('stg_ga4__events') }}
            WHERE
                event_name = '{{ event_name }}'
        )

        SELECT * FROM {{ event_name }}

    {% endfor %}

{% endmacro %}


        -- {% set get_event_params %}

        -- SELECT
        --     (
        --     SELECT
        --         key
        --     FROM   
        --         UNNEST(event_params)
        --     )
        -- FROM
        --     {{ ref('stg_ga4__events') }}

        -- {% endset %}

        -- {% set event_params_result = run_query(get_event_params) %}

        -- {% if execute %}
        -- {% set event_params = event_params_result.columns[0].values() %}
        -- {% else %}
        -- {% set event_params = [] %}
        -- {% endif %}


-- NEW MACRO TEST TO SET AS A VARIABLE INSTEAD --
{% macro get_event_names() %}

    SELECT DISTINCT
        event_name
    FROM   
        {{ ref('stg_ga4__events') }}

{% endmacro %}


{% macro get_event_params(event_name) %}

    SELECT DISTINCT
        key
    FROM   
        {{ ref('stg_ga4__events') }},
        UNNEST(event_params)
    WHERE
        event_name = {{ event_name }}

{% endmacro %}
