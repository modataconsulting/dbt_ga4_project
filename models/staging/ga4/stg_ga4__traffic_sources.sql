WITH unnest_traffic_sources AS (

    SELECT
        event_key,
        traffic_source.medium AS medium,
        traffic_source.name   AS campaign,
        traffic_source.source AS source
    FROM
        {{ ref('stg_ga4__events') }}

),

add_source_categories AS (

    SELECT
        event_key,
        source,
        medium,
        campaign,
        ga4_source_categories.source_category AS source_category
    FROM
        unnest_traffic_sources
        LEFT JOIN {{ ref('ga4_source_categories') }} USING (source)

),

set_default_channel_grouping AS (

    SELECT
        * EXCEPT (source_category),

        {{ default_channel_grouping('source', 'medium', 'source_category') }} AS default_channel_grouping
    FROM
        add_source_categories

),

renest_traffic_sources AS (

    SELECT
        event_key,

        STRUCT(
            source,
            medium,
            campaign,
            default_channel_grouping
        ) AS traffic_source
    FROM
       set_default_channel_grouping 

)

SELECT * FROM renest_traffic_sources