{%- macro get_query_params(query_string) -%}

        (
            SELECT
                ARRAY_AGG(
                    STRUCT(
                        params[SAFE_OFFSET(0)] AS key,
                        params[SAFE_OFFSET(1)] AS value
                    )
                )
            FROM (
                SELECT SPLIT(pairs, '=') AS params
                FROM UNNEST({{ query_string }}) AS pairs
            )
        )

{%- endmacro %}


-- EXPLICIT METHOD OF UNNESTING --
{%- macro get_query_params_2() -%}

    {% set query %}

    SELECT DISTINCT
        LOWER(REGEXP_REPLACE(REPLACE(TRIM(SPLIT(params, '=')[SAFE_OFFSET(0)]), '-', '_'), r'\W', '')) AS key
    FROM 
        {{ ref('stg_ga4__events') }},
        UNNEST(SPLIT(page_query_string, '&')) AS params
        
    {% endset %}

    {% set query_results = run_query(query) %}

    {% if execute %}
        {%- set results = query_results -%}
    {%- else -%}
        {%- set results = [] -%}
    {%- endif -%}

    {{ return(results) }}

{%- endmacro %}


-- IMPLICIT METHOD OF UNNESTING --
{%- macro get_query_params_3() -%}

    {% set query %}

    SELECT DISTINCT
        SPLIT(params, '=')[SAFE_OFFSET(0)] AS key
    FROM 
        {{ ref('stg_ga4__events') }},
        UNNEST(SPLIT(page_query_string, '&')) AS params
    WHERE
        SPLIT(params, '=')[SAFE_OFFSET(0)] IN UNNEST({{ var('included__query_params') }})
        
    {% endset %}

    {% set query_results = run_query(query) %}

    {% if execute %}
        {%- set results = query_results -%}
    {%- else -%}
        {%- set results = [] -%}
    {%- endif -%}

    {{ return(results) }}

{%- endmacro %}