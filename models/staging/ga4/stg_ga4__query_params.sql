-- TESTING THE MODEL HERE, LOL NO 'query_params' TO TEST AGAINST THO :/ --

WITH event_and_query_string AS (

    SELECT
        event_key,
        SPLIT(page_query_string, '&') AS query_string_split
    FROM
        {{ ref('stg_ga4__events') }}

),

flattened_query_string AS (

    SELECT
        event_key,
        params
    FROM
        event_and_query_string,
        UNNEST(query_string_split) AS params

),

split_param_value AS (

    SELECT
        event_key,
        SPLIT(params, '=')[SAFE_OFFSET(0)] AS param,
        NULLIF(SPLIT(params, '=')[SAFE_OFFSET(1)], '') AS value
    FROM
        flattened_query_string

)

SELECT * FROM split_param_value