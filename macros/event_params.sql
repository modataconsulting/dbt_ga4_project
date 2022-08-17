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