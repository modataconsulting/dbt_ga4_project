WITH users AS (

    SELECT
        *
    FROM
        {{ ref('int_ga4__users_grouped') }}

)

SELECT * FROM users