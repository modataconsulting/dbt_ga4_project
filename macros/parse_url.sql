-- INCLUDE DESCRIPTION HERE TO DESCRIBE MACRO FILE --

-- INCLUDE DESCRIPTION HERE TO DESCRIBE SPECIFIC MACRO --
{%- macro extract_hostname_from_url(url) -%}

        REGEXP_EXTRACT(
            {{ url }},
            '(?:http[s]?://)?(?:www\\.)?(.*?)(?:(?:/|:)(?:.)*|$)'
        )

{%- endmacro -%}

-- INCLUDE DESCRIPTION HERE TO DESCRIBE SPECIFIC MACRO --
{%- macro extract_query_string_from_url(url) -%}

        REGEXP_EXTRACT(
            {{ url }},
            '\\?(.+)'
        )

{%- endmacro -%}

-- INCLUDE DESCRIPTION HERE TO DESCRIBE SPECIFIC MACRO --
{%- macro remove_query_parameters(url, parameters) -%}

        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(
                        {{ url }},
                        '(\\?|&)({{ parameters|join("|") }})=[^&]*',
                        '\\1'
                    ),
                    '\\?&+',
                    '?'
                ),
                '&+',
                '&'
            ),
            '\\?$|&$',
            ''
        )

{%- endmacro -%}