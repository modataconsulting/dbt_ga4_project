{% macro get_engagement_events() %}

    {% set query %}

    SELECT DISTINCT
        event_name
    FROM   
        {{ ref('stg_ga4__events') }}
    
    {% if var('excluded__engagement_events', none) or var('conversion_events', none) is not none -%}
    WHERE
    {%- endif %}
    
        {% if var('excluded__engagement_events', none) is not none -%}
        event_name NOT IN UNNEST({{ var('excluded__engagement_events') }})
        {%- endif %}

        {% if var('conversion_events', none) is not none -%}
        AND event_name NOT IN UNNEST({{ var('conversion_events') }})
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