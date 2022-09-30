{%- macro default_channel_grouping(source, medium, source_category) -%}

        CASE
            WHEN {{ source }} IS NULL
            AND {{ medium }} IS NULL THEN 'Direct'

            WHEN {{ source }} = '(direct)'
            AND (
                {{ medium }} = '(none)'
                OR {{ medium }} = '(not set)'
            ) THEN 'Direct'

            WHEN REGEXP_CONTAINS(
                {{ source }},
                r'^(facebook|instagram|pinterest|reddit|twitter|linkedin)'
            ) = TRUE
            AND REGEXP_CONTAINS({{ medium }}, r'^(cpc|ppc|paid)') = TRUE THEN 'Paid Social'

            WHEN REGEXP_CONTAINS(
                {{ source }},
                r'^(facebook|instagram|pinterest|reddit|twitter|linkedin)'
            ) = TRUE
            OR REGEXP_CONTAINS(
                {{ medium }},
                r'^(social|social-network|social-media|sm|social network|social media)'
            ) = TRUE
            OR {{ source_category }} = 'SOURCE_CATEGORY_SOCIAL' THEN 'Organic Social'

            WHEN REGEXP_CONTAINS({{ medium }}, r'email|e-mail|e_mail|e mail') = TRUE
            OR REGEXP_CONTAINS({{ source }}, r'email|e-mail|e_mail|e mail') = TRUE THEN 'Email'

            WHEN REGEXP_CONTAINS({{ medium }}, r'affiliate|affiliates') = TRUE THEN 'Affiliates'

            WHEN {{ medium }} = 'referral' THEN 'Referral'

            WHEN {{ source_category }} = 'SOURCE_CATEGORY_SHOPPING'
            AND REGEXP_CONTAINS({{ medium }}, r'^(.*cp.*|ppc|paid.*)$') THEN 'Paid Shopping'

            WHEN REGEXP_CONTAINS({{ medium }}, r'^(cpc|ppc|paidsearch)$') THEN 'Paid Search'

            WHEN REGEXP_CONTAINS({{ medium }}, r'^(display|cpm|banner)$') THEN 'Display'

            WHEN REGEXP_CONTAINS({{ medium }}, r'^(cpv|cpa|cpp|content-text)$') THEN 'Other Advertising'

            WHEN {{ medium }} = 'organic'
            OR {{ source_category }} = 'SOURCE_CATEGORY_SEARCH' THEN 'Organic Search'

            WHEN REGEXP_CONTAINS({{ medium }}, r'^(.*video.*)$')
            OR {{ source_category }} = 'SOURCE_CATEGORY_VIDEO' THEN 'Organic Video'

            WHEN {{ source_category }} = 'SOURCE_CATEGORY_SHOPPING' THEN 'Organic Shopping'

            WHEN {{ medium }} = 'audio' THEN 'Audio'

            WHEN {{ medium }} = 'sms' THEN 'SMS'

            ELSE '(Other)'
        END 

{%- endmacro -%}