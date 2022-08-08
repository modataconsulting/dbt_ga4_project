-- INCLUDE DESCRIPTION HERE TO DESCRIBE MACRO FILE --

-- GONNA NEED TO FIX THE WHITESPACE ON THIS FORMATTING AS WELL -- 
{%- macro get_position(position, by_column_name, from_column_name) -%}

        {{ position }}_VALUE({{ from_column_name }}) OVER (
            PARTITION BY {{ by_column_name }}
            ORDER BY
                event_timestamp ROWS BETWEEN UNBOUNDED PRECEDING
                AND UNBOUNDED FOLLOWING
        )

{%- endmacro -%}