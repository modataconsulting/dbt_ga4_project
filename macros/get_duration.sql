{%- macro get_total_duration(duration_column) -%}

    CAST(
        CAST(
            ROUND(
                SUM({{ duration_column }} / 1000)
            )
        AS STRING)
    AS TIME FORMAT 'SSSSS')

{%- endmacro -%}

{%- macro get_avg_duration(duration_column, over_column = 'session_key') -%}

    CAST(
        CAST(
            ROUND(
                SUM({{ duration_column }} / 1000) / COUNT(DISTINCT {{ over_column }})
            )
        AS STRING)
    AS TIME FORMAT 'SSSSS')

{%- endmacro -%}