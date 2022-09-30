{% macro get_events() %}

    {% set query %}

    SELECT DISTINCT
        event_name
    FROM   
        {{ ref('stg_ga4__events') }}
    
    {% if var('excluded__events', none) | length > 0 -%}
    WHERE
        event_name NOT IN UNNEST({{ var('excluded__events') }})
    {%- endif %}

    {% endset %}

    {% set query_results = run_query(query) %}

    {% if execute %}
        {%- set results = query_results -%}
    {%- else -%}
        {%- set results = [] -%}
    {%- endif -%}

    {{ return(results) }}

{% endmacro %}