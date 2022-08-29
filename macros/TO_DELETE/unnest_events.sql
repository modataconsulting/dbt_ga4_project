-- NOTE: THIS WILL SERVE AS A STORE FOR ALL PREVIOUS ATTEMPTS AT CREATING THE MACRO FOR FUTURE REFERENCE IF ANY USEFUL GOODIES ARE LEFT IN HERE --
--------------------------------------------------------------------------------------------------------------------------------------------------

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


{% macro get_event_params_keys(event_name) %}

    SELECT DISTINCT
        key
    FROM   
        {{ ref('stg_ga4__events') }},
        UNNEST(event_params)
    WHERE
        event_name = {{ event_name }}

{% endmacro %}

--------------------------------------------
-- ORIGINALLY FROM 'event_params' MACRO FILE
--------------------------------------------


-------------------------------------------------------------------------------------------
-- #1: CREATE TABLE OF UNIQUE `event_params` BY `key` AND THEIR RESPECTIVE `value_type`. --
{%- macro get_event_param_value_types(key) -%}

    SELECT
        CASE
            WHEN COUNTIF(value.string_value IS NOT NULL) > 0 THEN 'string'
            WHEN COUNTIF(value.int_value IS NOT NULL) > 0 THEN 'int'
            WHEN COUNTIF(value.float_value IS NOT NULL) > 0 THEN 'float'
            WHEN COUNTIF(value.double_value IS NOT NULL) > 0 THEN 'double'
            ELSE NULL
        END AS value_type
    FROM
        {{ ref('stg_ga4__events') }},
        UNNEST(event_params)
    WHERE
        key = '{{ key }}'
    GROUP BY
        key

{%- endmacro %}

-- OR ALL IN ONE, LIKE THIS?? --
{%- macro new_unnest_by_key(column_to_unnest, key_to_extract) -%}

    {%- set get_event_param_value_type -%}
        SELECT
            CASE
                WHEN COUNTIF(value.string_value IS NOT NULL) > 0 THEN 'string'
                WHEN COUNTIF(value.int_value IS NOT NULL) > 0 THEN 'int'
                WHEN COUNTIF(value.float_value IS NOT NULL) > 0 THEN 'float'
                WHEN COUNTIF(value.double_value IS NOT NULL) > 0 THEN 'double'
                ELSE NULL
            END AS value_type
        FROM
            {{ ref('stg_ga4__events') }},
            UNNEST(event_params)
        WHERE
            key = '{{ key_to_extract }}'
            AND (
                value.string_value IS NOT NULL
                OR value.int_value IS NOT NULL
                OR value.float_value IS NOT NULL
                OR value.double_value IS NOT NULL
            )
        GROUP BY
            key
    {%- endset -%}

    {%- set value_type = dbt_utils.get_query_results_as_dict(get_event_param_value_type) -%}
    {%- set value_type = value_type["value_type"] | replace('(', '') | replace(')', '') | replace(',', '') | replace("'", "") %}

        (
            SELECT
                value.{{ value_type }}_value
            FROM
                UNNEST({{ column_to_unnest }})
            WHERE
                key = '{{ key_to_extract }}'
        ) AS {{ key_to_extract }}

{%- endmacro -%}

-- YO, THIS ACTUALLY WORKS!!!??? --
--------------------------------------------------------------------------------
-- {%- set get_event_params_and_values -%}

--     SELECT
--         event_params.key AS event_param_key,
--         CASE
--             WHEN event_params.value.string_value IS NOT NULL THEN 'string'
--             WHEN event_params.value.int_value IS NOT NULL THEN 'int'
--             WHEN event_params.value.float_value IS NOT NULL THEN 'float'
--             WHEN event_params.value.double_value IS NOT NULL THEN 'double'
--             ELSE NULL
--         END AS event_param_value
--     FROM
--         {{ ref('stg_ga4__events') }},
--         UNNEST(event_params) AS event_params
--     WHERE
--         event_params.key NOT IN UNNEST({{ var('excluded_event_params') }})
--         AND (
--             event_params.value.string_value IS NOT NULL
--             OR event_params.value.int_value IS NOT NULL
--             OR event_params.value.float_value IS NOT NULL
--             OR event_params.value.double_value IS NOT NULL
--         )
--     GROUP BY
--         event_param_key,
--         event_param_value
--     ORDER BY
--         event_param_key

-- {%- endset -%}

-- {%- set event_params_and_values = run_query(get_event_params_and_values) -%}

-- {%- if execute -%}
-- {%- set event_params = event_params_and_values -%}
-- {%- else -%}
-- {%- set event_params = [] -%}
-- {%- endif -%}

-- SELECT
--     *,

--     {% for event_param in event_params -%}

--     {{ unnest_by_key('event_params', event_param['event_param_key'], event_param['event_param_value']) }}
    
--     {{- "," if not loop.last }}
--     {% endfor %}
-- FROM
--     {{ ref('stg_ga4__events') }}
-- ORDER BY
--     event_value_in_usd DESC

--------------------------------------------------------------



-- IDEA --
-- WITH event_names_params_and_values AS (SELECT

--     event_name,
--     event_params.key AS event_parameter_key,
--     CASE
--         WHEN event_params.value.string_value IS NOT NULL THEN 'string'
--         WHEN event_params.value.int_value IS NOT NULL THEN 'int'
--         WHEN event_params.value.double_value IS NOT NULL THEN 'double'
--         WHEN event_params.value.float_value IS NOT NULL THEN 'float'
--         ELSE NULL
--     END AS event_parameter_value
-- FROM
--     {{ ref('stg_ga4__events') }},
--     UNNEST(event_params) AS event_params
-- WHERE
--     event_params.key NOT IN UNNEST({{ var('excluded_event_params') }})
--     AND (
--         event_params.value.string_value IS NOT NULL
--         OR event_params.value.int_value IS NOT NULL
--         OR event_params.value.float_value IS NOT NULL
--         OR event_params.value.double_value IS NOT NULL
--     )
-- GROUP BY
--     event_name,
--     event_parameter_key,
--     event_parameter_value
-- ORDER BY
--     event_name,
--     event_parameter_key

-- ),





------------------------
-- SCRATCH WORK BELOW --
        -- {%- set get_event_param_value_type -%}

        --     SELECT
        --         CASE
        --             WHEN COUNTIF(value.string_value IS NOT NULL) > 0 THEN 'string'
        --             WHEN COUNTIF(value.int_value IS NOT NULL) > 0 THEN 'int'
        --             WHEN COUNTIF(value.float_value IS NOT NULL) > 0 THEN 'float'
        --             WHEN COUNTIF(value.double_value IS NOT NULL) > 0 THEN 'double'
        --             ELSE NULL
        --         END AS value_type
        --     FROM
        --     {{ ref('stg_ga4__events') }},
        --     UNNEST(event_params)
        --     WHERE
        --         key = '{{ key_to_extract }}'
        --     GROUP BY
        --     key

        -- {%- endset -%}

        -- {%- set event_param_value_type = run_query(get_event_param_value_type) -%}

        -- {%- if execute -%}
        -- {%- set value_type = event_param_value_type.columns[0].values() -%}
        -- {%- else -%}
        -- {%- set value_type = [] -%}
        -- {%- endif -%}

-- Original get_event_param_value_types() Macro --
    -- SELECT
    --     key,
    --     CASE
    --         WHEN COUNTIF(value.string_value IS NOT NULL) > 0 THEN 'string'
    --         WHEN COUNTIF(value.int_value IS NOT NULL) > 0 THEN 'int'
    --         WHEN COUNTIF(value.float_value IS NOT NULL) > 0 THEN 'float'
    --         WHEN COUNTIF(value.double_value IS NOT NULL) > 0 THEN 'double'
    --         ELSE NULL
    --     END AS value_type
    -- FROM
    -- {{ ref('stg_ga4__events') }},
    -- UNNEST(event_params)
    -- GROUP BY
    -- 1



------------------------
-- EVEN MORE--
-- {{
--   config(
--     materialized="table"
--   )
-- }}

-- -- TESTING THE MACRO HERE, VERY MUCH STILL A WORK IN PROGESS --
-- {%- set event_names = dbt_utils.get_column_values(
--     table = ref('stg_ga4__events'),
--     column = 'event_name'
-- ) | unique %}

-- WITH base AS (

--     SELECT
--         *
--     FROM
--         {{ ref('stg_ga4__events') }}

-- ),

-- {%- for event_name in event_names %}

-- {{ event_name }}_with_params AS (

--     {%- set get_event_params -%}

--         SELECT DISTINCT
--             key
--         FROM   
--             {{ ref('stg_ga4__events') }},
--             UNNEST(event_params)
--         WHERE
--             event_name = '{{ event_name }}'
--             AND key NOT IN UNNEST({{ var('excluded_event_params') }})
--             AND (
--                 value.string_value IS NOT NULL
--                 OR value.int_value IS NOT NULL
--                 OR value.float_value IS NOT NULL
--                 OR value.double_value IS NOT NULL
--             )

--     {%- endset %}

--     {%- set event_params_results = run_query(get_event_params) -%}

--     {%- if execute -%}
--     {%- set event_params = event_params_results.columns[0].values() -%}
--     {%- else -%}
--     {%- set event_params = [] -%}
--     {%- endif %}

--     SELECT
--         *,

--         {%- for event_param in event_params -%}

--         {{ new_unnest_by_key('event_params', event_param) }}
        
--         {{- "," if not loop.last }}
--         {%- endfor %}
--     FROM
--         {{ ref('stg_ga4__events') }}
--     WHERE
--         event_name = '{{ event_name }}'

-- ),

-- {%- if loop.last %}

-- last_event AS (

--     SELECT
--         *
--     FROM
--         {{ event_name }}__with_params

-- )

-- {%- endif -%}
-- {% endfor %}

-- SELECT * FROM last_event



-- -------------------------
-- -- TRY THIS NOW: --

-- {%- set get_event_params_and_values -%}

--     SELECT
--         event_params.key AS event_param_key,
--         CASE
--             WHEN event_params.value.string_value IS NOT NULL THEN 'string'
--             WHEN event_params.value.int_value IS NOT NULL THEN 'int'
--             WHEN event_params.value.double_value IS NOT NULL THEN 'double'
--             WHEN event_params.value.float_value IS NOT NULL THEN 'float'
--             ELSE NULL
--         END AS event_param_value
--     FROM
--         {{ ref('stg_ga4__events') }},
--         UNNEST(event_params) AS event_params
--     WHERE
--         event_params.key NOT IN UNNEST({{ var('excluded_event_params') }})
--         AND (
--             event_params.value.string_value IS NOT NULL
--             OR event_params.value.int_value IS NOT NULL
--             OR event_params.value.float_value IS NOT NULL
--             OR event_params.value.double_value IS NOT NULL
--         )
--     GROUP BY
--         event_param_key,
--         event_param_value
--     ORDER BY
--         event_param_key

-- {%- endset -%}

-- {%- set event_params_and_values = run_query(get_event_params_and_values) -%}

-- {%- if execute -%}
-- {%- set event_params = event_params_and_values -%}
-- {%- else -%}
-- {%- set event_params = [] -%}
-- {%- endif -%}

-- SELECT
--     *,

--     {% for event_param in event_params -%}

--     {{ unnest_by_key('event_params', event_param['event_param_key'], event_param['event_param_value']) }}
    
--     {{- "," if not loop.last }}
--     {% endfor %}
-- FROM
--     {{ ref('stg_ga4__events') }}
-- ORDER BY
--     60 DESC



