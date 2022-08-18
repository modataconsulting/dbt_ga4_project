WITH events AS (

    SELECT
        *
    FROM
        {{ ref('int_ga4__events_joined') }}

)

SELECT * FROM events