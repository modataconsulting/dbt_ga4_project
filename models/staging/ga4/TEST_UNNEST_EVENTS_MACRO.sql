-- TESTING THE MACRO HERE, VERY MUCH STILL A WORK IN PROGESS --
{% set event_names_results = run_query(get_event_names()) %}

{% if execute %}
{% set event_names = event_names_results.columns[0].values() %}
{% else %}
{% set event_names = [] %}
{% endif %}

{{ unnest_events(event_names) }}
