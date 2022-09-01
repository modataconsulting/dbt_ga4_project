{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'insert_overwrite',
        partition_by = {
            "field": "page_date",
            "data_type": "date"
        },
        cluster_by = "page_path"
    )
}}

WITH pages AS (

    SELECT
        *
    FROM
        {{ ref('int_ga4__pages_grouped') }}

)

SELECT * FROM pages