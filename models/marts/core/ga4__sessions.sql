{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'insert_overwrite',
        partition_by = {
            "field": "session_date",
            "data_type": "date"
        },
        cluster_by = "user_key"
    )
}}

WITH sessions AS (

    SELECT
        *
    FROM
        {{ ref('int_ga4__sessions_grouped') }}

)

SELECT * FROM sessions