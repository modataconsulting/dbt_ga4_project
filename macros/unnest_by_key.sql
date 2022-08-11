-- Unnests a single key's value from an array

{%- macro unnest_by_key(column_to_unnest, key_to_extract, value_type = "string", rename_column = "default") %}
        (SELECT
            value.{{ value_type }}_value
        FROM
            UNNEST({{ column_to_unnest }})
        WHERE
            key = '{{ key_to_extract }}'
        ) AS

        {%- if rename_column == "default" %}
            {{ key_to_extract }}
        {%- else %}
            {{ rename_column }}
        {%- endif -%}
{%- endmacro -%}

-- REFACTORING MACRO --
{%- macro unnest_by_key2(column_to_unnest, key_to_extract, value_type = "string") %}
        
        (
        SELECT
            value.{{ value_type }}_value
        FROM
            UNNEST({{ column_to_unnest }})
        WHERE
            key = '{{ key_to_extract }}'
        )

{%- endmacro -%}

-- ALL OF THESE NEED A WAY OF CHECK FOR NULL BEFORE ACTUALLY TRYING TO QUERY AND FAILING... --
-- PSUEDO LOGIC FOR AUTO-DETERMINING THE VALUE_TYPE -- (IS DEF BETTER?)
{% if value_type("string") is not null %} -- CHECK: IF STRING NOT NULL, USE STRING, ELSE PASS --
    value_type = "string"
{% elif value_type("int") is not null %}
    value_type = "float"
{% elif value_type("int") is not null %}
    value_type = "double"
{% endif %}


-- OTHER WAY --
{% if value_type("string") is null and value_type("int") is not null %} -- CHECK: IF STRING NULL, CHECK INT FIRST, ELSE PASS --
    value_type = "int"
{% elif value_type("float") is not null %}
    value_type = "float"
{% else %}
    value_type = "double"
{% endif %}

-- EVEN BETTER ROUTE? --
{% for value_type in value.value_types %} -- CAN REMOVE 'if not value_type("string")', BUT IS THERE A BENEFIT TO SPECIFYING IT? --
    {% if value_type is not null %}
        {{ value_type }}
    {% endif %}
{% endfor %}


