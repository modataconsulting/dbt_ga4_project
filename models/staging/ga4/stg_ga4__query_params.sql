-- I'M THINKING WE ACTUALLY GO EXPLICIT FOR QUERY_PARAMS INSTEAD OF IMPLICIT UNNESTING, WAY TOO MANY POTENTIALLY UNWANTED PARAMS COULD BE IN THE URL --

WITH split_query_string AS (

    SELECT
        event_key,
        SPLIT(page_query_string, '&') AS query_string
    FROM
        {{ ref('stg_ga4__events') }}
    WHERE
        page_query_string IS NOT NULL

),

split_query_params AS (

    SELECT
        event_key,

        {{ get_query_params('query_string') }} AS query_params
    FROM
        split_query_string

),

final_query_params AS (

    SELECT
        event_key,

        STRUCT(        
            {% for query_param in get_query_params_3() -%}

            {{ unnest_by_key_2('query_params', query_param['key']) }}
            
            {{- "," if not loop.last }}
            {% endfor %}
        ) AS query_params
    FROM
        split_query_params

)

SELECT * FROM final_query_params