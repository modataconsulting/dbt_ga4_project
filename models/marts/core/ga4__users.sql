{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'insert_overwrite',
        partition_by = {
            "field": "first_seen_date",
            "data_type": "date"
        },
        cluster_by = "last_seen_date",
    )
}}

WITH users AS (

    SELECT
        *
    FROM
        {{ ref('int_ga4__users_grouped') }}

)

SELECT * FROM users