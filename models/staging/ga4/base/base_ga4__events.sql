{%- if var('static_incremental_days', false) -%}
    {% set partitions_to_replace = [] %}
    
    {% for i in range(var('static_incremental_days')) %}
        {% set partitions_to_replace = partitions_to_replace.append('date_sub(current_date, interval ' + (i+1)|string + ' day)') %}
    {% endfor %}
    {{
        config(
            materialized = 'incremental',
            incremental_strategy = 'insert_overwrite',
            partition_by = {
                "field": "event_date",
                "data_type": "date",
            },
            partitions = partitions_to_replace,
        )
    }}
{%- else -%}
    {{
        config(
            materialized = 'incremental',
            incremental_strategy = 'insert_overwrite',
            partition_by = {
                "field": "event_date",
                "data_type": "date",
            },
        )
    }}
{%- endif -%}

-- BigQuery does not cache wildcard queries that scan across sharded tables which means it's best to materialize the raw event data as a partitioned table so that future queries benefit from caching.

WITH source AS (

    SELECT 
        PARSE_DATE('%Y%m%d', event_date) AS event_date,
        TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,
        event_name,
        event_params,
        TIMESTAMP_MICROS(event_previous_timestamp) AS event_previous_timestamp,
        event_value_in_usd,
        event_bundle_sequence_id,
        TIMESTAMP_MICROS(event_server_timestamp_offset) AS event_server_timestamp_offset,
        user_id,
        user_pseudo_id,
        privacy_info,
        user_properties,
        TIMESTAMP_MICROS(user_first_touch_timestamp) AS user_first_touch_timestamp,
        user_ltv,
        device,
        geo,
        app_info,
        traffic_source,
        stream_id,
        platform,
        ecommerce,
        items
    FROM
        {{ source('ga4', 'events') }}
    WHERE
        _TABLE_SUFFIX NOT LIKE '%intraday%'
        AND CAST(_TABLE_SUFFIX AS INT64) >= {{ var('start_date') }}

    {%- if is_incremental() %}
        
        -- Incrementally add new events. Filters on _TABLE_SUFFIX using the max event_date value found in {{ this }}.
        -- See https://docs.getdbt.com/reference/resource-configs/bigquery-configs#the-insert_overwrite-strategy
        AND PARSE_DATE('%Y%m%d', _TABLE_SUFFIX) >= _dbt_max_partition

    {%- endif %}

),

renamed as (

    SELECT 
        event_date,
        event_timestamp,
        LOWER(REPLACE(TRIM(event_name), ' ', '_')) AS event_name, -- Clean up all event names to be snake cased
        event_params,
        event_previous_timestamp,
        event_value_in_usd,
        event_bundle_sequence_id,
        event_server_timestamp_offset,
        user_id,
        user_pseudo_id,
        privacy_info,
        user_properties,
        user_first_touch_timestamp,
        user_ltv,
        device,
        geo,
        app_info,
        traffic_source,
        stream_id,
        platform,
        ecommerce,
        items,

        -- DEFINATELY REFACTOR WITH MACRO TO BE DRY & DYNAMIC, USE IF/ELSE TO AUTO DETERMIN WHETHER IT WOULD BE STRING OR INT_VALUE -- 
        {{ unnest_by_key('event_params', 'ga_session_id', 'int') }},
        {{ unnest_by_key('event_params', 'page_location') }},
        {{ unnest_by_key('event_params', 'ga_session_number',  'int') }},
        
        -- REFACTOR THIS & THE MACRO TO NOT INCLUDE AS TO FIX THIS REOCCURING ISSUE --
        -- CASE
        --     WHEN (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'session_engaged') = '1' THEN 1
        -- END AS session_engaged,

        -- TRY USING THIS INSTEAD --
        IF({{ unnest_by_key2('event_params', 'session_engaged') }} = '1', 1, NULL) AS session_engaged, -- USE NULL OR 0? --
        
        {{ unnest_by_key('event_params', 'engagement_time_msec', 'int') }},
        {{ unnest_by_key('event_params', 'page_title') }},
        {{ unnest_by_key('event_params', 'page_referrer') }},
        {{ unnest_by_key('event_params', 'source') }},
        {{ unnest_by_key('event_params', 'medium') }},
        {{ unnest_by_key('event_params', 'campaign') }},

        IF(event_name = 'page_view', 1, 0) AS is_page_view,
        IF(event_name = 'purchase', 1, 0) AS is_purchase
    FROM source

)

SELECT * FROM renamed