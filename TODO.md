# TODO
## Low LOE
### Adding & Fixing Docs:
- [ ] Docs to Add:
	- [ ] Add a singular `_metric_definitions.md` file to root of the `models` folder. See [here](https://gitlab.com/gitlab-data/analytics/-/tree/master/transform/snowflake-dbt/models) for inspo.
		- [ ] Essentially each metric definition would be in this format: `{% docs %} <Enter your metric definition here, like this. [Source](https://like-to-source-file.here/)> {% enddocs %}`
	- [ ] 
- [ ] Docs to Fix:
	- [ ] Change `__overview__.md` to simply be a high-level overview with links to say the `README.md`, `Projet Style Guide`, and the `whatever else here` for the project.
		- [ ] See [here](https://gitlab.com/gitlab-data/analytics/-/blob/master/transform/snowflake-dbt/models/overview.md) for inspo.
	- [ ] 
### Metric & Dimension Renaming:
The general Fixes are as follows:
```
num_[entity] --> 
total_[entity] OR
[entity] (**Recommended**)

// EX: num_page_views --> page_views
```
- [ ] `dim_ga4__users` table:
	- [ ] `num_sessions` --> `sessions`
	- [ ] `num_page_views` --> `pages_views`
	- [ ] `num_purchases` --> `purchases`
- [x] `dim_ga4__sessions` table:
- [ ] `fct_ga4__pages` table:
	- [ ]  Consider if we should handle `hour` differently?
	- [ ] `total_time_on_page` --> `time_on_page`
- [ ] `fct_ga4__sessions` table:
	- [ ] `count_page_views` --> `page_views`
	- [ ] Consider changing `sum_event_value_in_usd` --> `event_value`, will want to allign with UA/Internal usage.
	- [ ] `session_engaged` --> `engaged_session`?

## Medium LOE
### Mart Table Restructuring:
REASONING: **Wide & Denomalized.** Unlike old school warehousing, in the modern data stack storage is cheap and it’s compute that is expensive and must be prioritized as such, packing these into very wide denormalized concepts that can provide everything somebody needs about a concept as a goal.
- [ ] `dim_ga4__sessions` & `fct_ga4__sessions` --> `ga4__sessions`
- [ ] `dim_ga4__users` --> `ga4__users`
- [ ] `fct_ga4__pages` --> `ga4__pages`

### Adding Metrics & Dimensions:
#### Individual Metrics:
- [ ] `USER-SCOPE` Metrics:
	- [ ] `days_active` = `COUNT(DISTINCT event_date) AS day_count`: The number of days a user has been active on your website or application.
	- [ ] ?`event_count`? = `COUNT(*[events]) AS event_count`: The total number of a events a user has triggered on your webiste or application.

- [ ] IN GENERAL CONSIDER ADDING THESE FOR EACH METRIC WHERE APPLICABLE:
	- [ ] `avg_[entity]`
	- [ ] `total_[entity]`
	- [ ] `first_[entity]`
	- [ ] `last_[entity]`

#### Groups of Metrics:
- [ ] [User Lifetime](https://support.google.com/analytics/answer/9143382) Metrics:
	- [ ] `lifetime_engaged_sessions`: The number of engaged sessions a user had since they first visited your website or application.
	- [ ] `lifetime_engagemenet_duration`:The length of time since a user's first visit that the user was active on your website or application while it was in the foreground.
	- [ ] `lifetime_session_duration`: The total duration of user sessions, from their first session until the current session expires, including time when your website or application is in the background.
	- [ ] `lifetime_ad_revenue`: The ad revenue you generate from someone since their first visit to your website or app.
	- [ ] `LTV` or `lifetime_value`: Lifetime value (LTV) shows the total revenue from purchases on your website or application. You can use the data to determine how valuable users are based on additional revenue you generate.
	- [ ] `lifetime_sessions`: ALREADY HAVE THIS - `sessions` @ User Level
	- [ ] `lifetime_transactions` ALREADY HAVE THIS - `purchases` @ User Level
- [ ] ...WAY MORE...

## High LOE
### Creating A Dynamic Macro To Handle All Events:
REASONING: 
CURRENT PROGRESS: **I am so close, but no cigar yet.** I have almost figured out how to dynamically handle all `event_params` and their assosiated `value.<dtype>_type` through macros, one solved, I can implement it to build one enormous Staging Model for all non statically handled events.
- [ ] 

### Restructing Certain Staging Models --> Intermediate Models:
REASONING: Currently there is only a Staging and Mart Models, and no Intermediate layer. Additionally of the following models are breaking the underlying rule of Staging Models: **NO JOINS** & **NO AGGREGATION / RE-GRAINING**.
- [ ] Handling `conversion_events`:
	- [ ] 1. ADD A `stg_ga4__event_conversions` UPSTREAM INSTEAD OF HAVING BOTH `stg_ga4__page_conversions` AND `stg_ga4__session_conversions`.
	- [ ] 2. MOVE `stg_ga4__page_conversions` --> `int_ga4__page_conversions`, AND PULL FROM `stg_ga4__event_conversions`.
	- [ ] 3. MOVE `stg_ga4__session_conversions` --> `int_ga4__session_conversions`, AND PULL FROM `stg_ga4__event_conversions`.
- [ ] Handling `FIRST` & `LAST` events:
	- [ ] `stg_ga4__sessions_first_last_pageviews`
	- [ ] `stg_ga4__users_first_last_pageviews`
	- [ ] `stg_ga4__users_first_last_events`
- [ ] Handling `user_properties`:
	- [ ] `stg_ga4__users_properties`
	- [ ] `stg_ga4__derived_users_properties`
- [ ] Handling all `event_*` related models:
	- [ ] FIX `stg_ga4__event_page_view`, it is trying to join with something up stream.

## Other General Issues:
- [ ] Decide on considerations for handling certain `event_params`, such as: 
	- [ ] Google click-related: `gclsrc` and `gclid`.
		- [ ] See [here](https://support.google.com/searchads/answer/7342044) for more info.
	- [ ] Others like: `debug_mode`, `term`, and ?`clean_event`.


# COMPLETED
- [x]


# OTHER CONSIDERATIONS & IDEAS
- CHECK THIS RESOURCE OUT: [Data Modeling for a Customer 360 View](https://docs.getdbt.com/blog/customer-360-view-identity-resolution#step-3-model-the-gaggle).
- Monitoring [Core Web Vitals in BigQuery](https://web.dev/vitals-ga4/).
- [Churn Prediction Using GA4 and BQML](https://cloud.google.com/blog/topics/developers-practitioners/churn-prediction-game-developers-using-google-analytics-4-ga4-and-bigquery-ml).
- ADD IN ABITRARY SCALES OF 1 TO 10 FOR SAY SOMETHING LIKE `user_activity_scale` OR `user_engagement_scale`.
	- WHERE YOU COULD USE ~ `APPROX_QUANTILES(<metrric_name>, 100)[OFFSET(<percentage_amount>)] AS p<percentage_amount>`.
	- SEE [Sample Queries for Audiences](https://support.google.com/analytics/answer/9037342?hl=en&ref_topic=9359001#zippy=%2Cin-this-article) FOR MORE INSPORATION.
- IDEA FOR HOW TO HANDLE DYNAMIC UNNEST_BY_KEY FOR ALL NON HARD-CODED EVENT MODELS:
	- ESSENTIALLY SHOULD PASS A `exclude_event_params` VARIABLE LIST TO EXLUDE FOR EACH EVENT, MOST LIKELY INCLUDING THE FOLLOWING: 
		- `['ga_session_id', 'page_location', 'ga_session_number', 'session_engaged', 'engagement_time_msec', 'page_title', 'page_refferr', 'source', 'medium', 'campaign']`

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