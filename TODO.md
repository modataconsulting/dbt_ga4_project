## BAD METRIC/DIMENSION NAMES:
- num_[entity] --> 
	- total_[entity] or
	- [entity] (**Recommended**)
	- EX: num_page_views --> page_views
- 


## Table:
- dim_ga4__users:
	- **num_sessions --> sessions**
	- **num_page_views --> pages_views**
	- **num_purchases --> purchases**
- dim_ga4__sessions:
	- ?ga_session_number
	- REST LOOKS FINE
- fct_ga4__pages:
	- ?hour
	- **total_time_on_page --> time_on_page**
- fct_ga4__sessions:
	- ?count_page_views -- CHANGE THIS TO JUST `page_views`. --
	- ?sum_event_value_in_usd -- CHANGE THIS TO JUST `event_value`. --
	- ?session_engaged --> **OR** engaged_session?

##TODOs taken from the dbt_ga4 package:
- **"Merge and clean up dim_sessions & fct_sessions. Just consider it ga4__sessions and ga4__users."**

## MOVE CERTAIN STG MODELS TO BE INT MODELS:
- `stg_ga4__page_conversions`
- `stg_ga4__session_conversions`
- `stg_ga4__sessions_first_last_pageviews`
- `stg_ga4__users_first_last_pageviews`
- `stg_ga4__users_first_last_events`
- `stg_ga4__users_properties`
- `stg_ga4__derived_users_properties`
- FIX `stg_ga4__event_page_view`, it is trying to join with something up stream.

## Ideas to use:
- These [example queries for GA4](https://developers.google.com/analytics/bigquery/basic-queries) are perfect!
	- USE THIS, PERFECT SOLUTION!!! : `SELECT COALESCE(value.int_value, value.float_value, value.double_value)` FROM:
```
(
SELECT COALESCE(value.int_value, value.float_value, value.double_value)
FROM UNNEST(event_params)
WHERE key = 'value'
) AS event_value
```
	- IMPLEMENTATION WOULD PROB LOOK LIKE:
```
{% if value.string_value not null%}
value.string_value
{% else %}
COALESCE(value.int_value, value.float_value, value.double_value)
{% endif %}
```
- Monitoring [Core Web Vitals in BigQuery](https://web.dev/vitals-ga4/).
- [Churn Prediction Using GA4 and BQML](https://cloud.google.com/blog/topics/developers-practitioners/churn-prediction-game-developers-using-google-analytics-4-ga4-and-bigquery-ml).
- ADD IN ABITRARY SCALES OF 1 TO 10 FOR SAY SOMETHING LIKE `user_activity_scale` OR `user_engagement_scale`.
	- WHERE YOU COULD USE ~ `APPROX_QUANTILES(<metrric_name>, 100)[OFFSET(<percentage_amount>)] AS p<percentage_amount>`.
	- SEE [Sample Queries for Audiences](https://support.google.com/analytics/answer/9037342?hl=en&ref_topic=9359001#zippy=%2Cin-this-article) FOR MORE INSPORATION.
- IDEA FOR HOW TO HANDLE DYNAMIC UNNEST_BY_KEY FOR ALL NON HARD-CODED EVENT MODELS:
	- ESSENTIALLY SHOULD PASS A `exclude_event_params` VARIABLE LIST TO EXLUDE FOR EACH EVENT, MOST LIKELY INCLUDING THE FOLLOWING: 
		- `['ga_session_id', 'page_location', 'ga_session_number', 'session_engaged', 'engagement_time_msec', 'page_title', 'page_refferr', 'source', 'medium', 'campaign']`


## Individual Metrics & Dimensions to add:
- USER SCOPE Metrics:
	- `days_active` = `COUNT(DISTINCT event_date) AS day_count`: The number of days a user has been active on your website or application.
	- ?`event_count`? = `COUNT(*[events]) AS event_count`: The total number of a events a user has triggered on your webiste or application.

- SESSION SCOPE Metrics:
- IN GENERAL CONSIDER ADDING THESE FOR EACH METRIC WHERE APPLICABLE:
	- `avg_[entity]`
	- `total_[entity]`
	- `first_[entity]`
	- `last_[entity]`

## Larger groups of Metrics & Dimensions to add:
- [User Lifetime](https://support.google.com/analytics/answer/9143382) Metrics:
	- `lifetime_engaged_sessions`: The number of engaged sessions a user had since they first visited your website or application.
	- `lifetime_engagemenet_duration`:The length of time since a user's first visit that the user was active on your website or application while it was in the foreground.
	- `lifetime_session_duration`: The total duration of user sessions, from their first session until the current session expires, including time when your website or application is in the background.
	- `lifetime_ad_revenue`: The ad revenue you generate from someone since their first visit to your website or app.
	- `LTV` or `lifetime_value`: 	Lifetime value (LTV) shows the total revenue from purchases on your website or application. You can use the data to determine how valuable users are based on additional revenue you generate.
	- `lifetime_sessions`: ALREADY HAVE THIS - `sessions` @ User Level
	- `lifetime_transactions` ALREADY HAVE THIS - `purchases` @ User Level
- ...WAY MORE...