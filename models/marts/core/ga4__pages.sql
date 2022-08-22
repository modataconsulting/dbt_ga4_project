WITH pages AS (

    SELECT
        *
    FROM
        {{ ref('int_ga4__pages_grouped') }}

)

SELECT * FROM pages