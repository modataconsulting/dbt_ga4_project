{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'insert_overwrite',
        partition_by = {
            "field": "event_date",
            "data_type": "date"
        },
    )
}}

WITH events AS (

    SELECT
        *
    FROM
        {{ ref('int_ga4__events_joined') }}

)

SELECT * FROM events