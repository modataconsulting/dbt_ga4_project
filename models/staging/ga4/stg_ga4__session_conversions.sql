-- THIS FILE WILL DEF NEED SOME WORK --

{{
    config(
        enabled= var('conversion_events', false) != false
    )
}}

WITH events AS (

    SELECT
        1 AS event_count,
        session_key,
        event_name
    FROM
        {{ ref('stg_ga4__events') }}

),

sessions AS (

    SELECT DISTINCT
        session_key
    FROM
        events

),

-- For loop that creates 1 cte per conversions, grouped by session key.
{% for conv_event in var('conversion_events', []) %}

conversion_{{ conv_event }} AS (

    SELECT
        session_key,
        SUM(event_count) AS conversion_count
    FROM
        events
    WHERE
        event_name = '{{ conv_event }}'
    GROUP BY
        1

),

{% endfor %}

-- Finally, join in each conversion count as a new column
final_pivot AS (

    SELECT
        session_key

        {% for conv_event in var('conversion_events', []) %},

        IFNULL(conversion_{{ conv_event }}.conversion_count, 0) AS {{ conv_event }}_count

        {% endfor %}
    FROM
        sessions

        {% for conv_event in var('conversion_events', []) %}

        LEFT JOIN conversion_{{ conv_event }} USING (session_key)

        {% endfor %}

)

SELECT * FROM final_pivot