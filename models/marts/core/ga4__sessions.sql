WITH sessions AS (

    SELECT
        *
    FROM
        {{ ref('int_ga4__sessions_grouped') }}

)

SELECT * FROM sessions