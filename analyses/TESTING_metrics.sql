SELECT *
FROM {{ metrics.calculate(
    [metric('pageviews'), metric('avg_engagement_duration')],
    grain='day',
    dimensions=['page_path'],
) }}
WHERE
    avg_engagement_duration > 0
ORDER BY
    date_day DESC