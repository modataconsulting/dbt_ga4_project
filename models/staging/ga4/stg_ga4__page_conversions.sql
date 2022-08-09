-- THIS FILE WILL DEF NEED SOME WORK --

{{
    config(
        enabled= var('conversion_events', false) != false
    )
}}

WITH events AS (

    SELECT
        1 AS event_count,
        event_name,
        event_date,
        EXTRACT(
            HOUR
            FROM
                (
                    SELECT
                        TIMESTAMP_MICROS(event_timestamp)
                )
        ) AS hour,
        page_location
    FROM
        {{ ref('stg_ga4__events') }}

),

pk AS (

    SELECT DISTINCT
        CONCAT(
            CAST(event_date AS string),
            CAST(hour AS string),
            page_location
        ) AS page_key,
    FROM
        events

),

-- For loop that creates 1 cte per conversions, grouped by page_location.
{% for conv_event in var('conversion_events', []) %}

conversion_{{ conv_event }} AS (

    SELECT DISTINCT
        CONCAT(
            CAST(event_date AS string),
            CAST(hour AS string),
            page_location
        ) AS page_key,
        SUM(event_count) AS conversion_count,
    FROM
        events
    WHERE
        event_name = '{{ conv_event }}'
    GROUP BY
        1

),

{% endfor %}

-- Finally, join in each conversion count as a new column.
final_pivot AS (

    SELECT
        page_key

        {% for conv_event in var('conversion_events', []) %},

        IFNULL(conversion_{{ conv_event }}.conversion_count, 0) AS {{ conv_event }}_count

        {% endfor %}
    FROM
        pk

        {% for conv_event in var('conversion_events', []) %}

        LEFT JOIN conversion_{{ conv_event }} USING (page_key)

        {% endfor %}

)

SELECT * FROM final_pivot