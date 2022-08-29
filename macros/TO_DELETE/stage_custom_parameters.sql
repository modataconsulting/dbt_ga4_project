-- INCLUDE DESCRIPTION HERE TO DESCRIBE MACRO FILE --
-- MAY NEED TO FIX THE UNNEST_BY_KEY MACRO FOR THIS --

{% macro stage_custom_parameters(custom_parameters) %}

    {% for custom_param in custom_parameters %}
 
        ,{{ unnest_by_key('event_params',  custom_param.name ,  custom_param.value_type ) }}

    {% endfor %}

{% endmacro %}