# TODO
## Low LOE
### Adding & Fixing Docs:

- [ ] Docs to Add:
	- [x] Add a singular `_metric_definitions.md` file to root of the `models` folder. See [here](https://gitlab.com/gitlab-data/analytics/-/tree/master/transform/snowflake-dbt/models) for inspo.
		- [x] Essentially each metric definition would be in this format: `{% docs %} <Enter your metric definition here, like this. [Source](https://like-to-source-file.here/)> {% enddocs %}`
		- [ ] Need to update as metrics & dimensions are added, removed, or changed.
	- [ ] Add in [this](https://stackoverflow.com/a/62836622).
	- [x] Restructure to be:
		- [x] A single `__schema__.yml` file, for all sources & models at the root of A NEW `docs` folder.
			- [x] i.e., combine `_core__models.yml`, `_ga4__models.yml` & `_ga4__sources.yml`.
			- [x] REMOVE `_core__models.yml`, `_ga4__models.yml` & `_ga4__sources.yml`.
		- [x] A single `__macros__.yml` file.
			- [x] Rename `_macros.yml`, may choose to join this with the `__schema__.yml` file later if we can find fix for models failing to compile.
		- [x] A single `__docs__.md` file, for all model, metric, & macro definitions/descriptions at the root of A NEW `docs` folder.
			- [x] i.e., combine `_core__docs.md`, `_metric_definitions.md`, & `_docs.md`.
			- [x] REMOVE `_core__docs.md`, `_metric_definitions.md`, & `_docs.md`.
		- [x] Then also move `__overview__.md` to the root of A NEW `docs` folder.
- [ ] Docs to Fix:
	- [x] Change `__overview__.md` to simply be a high-level overview with links to say the `README.md`, `Projet Style Guide`, and the `whatever else here` for the project.
		- [x] See [here](https://gitlab.com/gitlab-data/analytics/-/blob/master/transform/snowflake-dbt/models/overview.md) for inspo.

### Metric & Dimension Renaming:

The general Fixes are as follows:
```
num_[entity] --> 
total_[entity] OR
[entity] (**Recommended**)

// EX: num_page_views --> page_views
```
- [x] `dim_ga4__users` table:
	- [x] `num_sessions` --> `sessions`
	- [x] `num_page_views` --> `pages_views`
	- [x] `num_purchases` --> `purchases`
- [x] `dim_ga4__sessions` table:
- [ ] `fct_ga4__pages` table:
	- [ ] Consider if we should handle `hour` differently?
	- [x] `total_time_on_page` --> `time_on_page` --> `total_engagement_duration`
- [ ] `fct_ga4__sessions` table:
	- [x] `count_page_views` --> `page_views`
	- [x] Consider changing `sum_event_value_in_usd` --> `event_value`, will want to allign with UA/Internal usage.
	- [ ] `session_engaged` --> `engaged_sessions`?
- [x] `ga4__events` table:
	- [x] Inlcude the `is_` prefix to all boolean fields (e.g. `session_enagaged`, `engaged_session_event`, `entrances`), to be like: `is_page_view`, `is_purchase`, etc.
	- [x] Add an additiona `page_path` metric.
 
### Macro Changes:
- [ ] Consider using the following `dbt.utils` in place of the current url-related macros:
	- [ ] [Web Macros](https://github.com/dbt-labs/dbt-utils/blob/main/README.md#web-macros)
- [ ] Consider recoupling the `extract_hostname_from_url` & `extract_query_string_from_url` into a singular `parse_url()` macro --> parse_url([hostname|query]):
	- [ ] Checks for `remove_query_parameters` automatically & simpler than having multiple macros with specific names.

## Medium LOE
### Mart Table Restructuring:

REASONING: **Wide & Denomalized.** Unlike old school warehousing, in the modern data stack storage is cheap and it’s compute that is expensive and must be prioritized as such, packing these into very wide denormalized concepts that can provide everything somebody needs about a concept as a goal.
- [ ] `dim_ga4__sessions` & `fct_ga4__sessions` --> `ga4__sessions`
- [ ] `dim_ga4__users` --> `ga4__users`
- [x] `fct_ga4__pages` --> `ga4__pages`
- [x] ALSO, HONESTLY SHOULD INCLUDE AN ENRICHED & UNNESTED `ga4__events` TABLE AS WELL.

### Adding Metrics & Dimensions:
#### Individual Metrics:

- [ ] `USER-SCOPE` Metrics:
	- [ ] `days_active` = `COUNT(DISTINCT event_date) AS day_count`: The number of days a user has been active on your website or application.
	- [ ] ?`event_count`? = `COUNT(*[events]) AS event_count`: The total number of a events a user has triggered on your webiste or application.
	- [ ] Event-related:
		- [ ] `avg_events_per_session`
		- [ ] `lifetime_events`
	- [ ] Pageview-related:
		- [ ] `avg_page_views_per_session`
		- [ ] `avg_page_view_duration`
	- [ ] Session-related:
		- [ ] `avg_session_duration`
		- [ ] `lifetime_session_duration` **SEE BELOW IN `User Lifetime Metrics`.**
- [ ] `SESSION-SCOPE` Metrics:
	- [ ] Event-related:
		- [ ] `avg_events_per_session`
		- [ ] `lifetime_events`
	- [ ] Pageview-related:
		- [ ] `avg_page_view_duration`
- [ ] `PAGE-SCOPE` Metrics:
	- [ ] Expand on [Entrances & Exits](https://support.google.com/analytics/answer/11080047?hl=en&ref_topic=11151952):
		- [x] `entrance_rate`: The percentage of sessions that started on a page or screen (`Entrances` / `Sessions`).
		- [x] `exit_rate`: The percentage of sessions that ended on a page or screen (`Exits` / `Sessions`).
	- [ ] Event-related:
		- [ ] `events_per_page`
	- [ ] Mirroring GA4 UI:
		- [x] `views`, just stick with `page_views`?
		- [x] `users`
		- [x] `new_users`
		- [ ] `views_per_user`
		- [x] `total_engagement_duration`
		- [x] `avg_engagement_duration`
		- [ ] `unique_user_scrolls`
		- [ ] ?`event_count` -- DECIDE HOW TO BREAK THESE ALL OUT --
		- [ ] ?`conversions` -- DECIDE HOW TO HANDLE GENERAL CONVERSION_EVENT LOGIC --
		- [ ] ?`total_revenue` -- CHOOSE 1 NAME, `event_value`, `total_evet_value`, `total_revenue`? --
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
	- [x] `lifetime_sessions`: **ALREADY HAVE THIS - `sessions` @ User Level**
	- [x] `lifetime_transactions` **ALREADY HAVE THIS - `purchases` @ User Level**
- [ ] ...WAY MORE...
- [ ] See [Automatically Collected Events in GA4](https://support.google.com/firebase/answer/9234069?hl=en).

## High LOE
### Creating A Dynamic Macro To Handle All Events:

REASONING: This will help the setup / configuartion to be almost instant. Where every event_name in the `stg_ga4_events` model will be automatically detected and create subsequent models for them.

CURRENT PROGRESS: **I am so close, but no cigar yet.** I have almost figured out how to dynamically handle all `event_params` and their assosiated `value.<dtype>_type` through macros, one solved, I can implement it to build one enormous Staging Model for all non statically handled events.
- [ ] 

### Restructing Certain Staging Models --> Intermediate Models:

REASONING: Currently there is only a Staging and Mart Models, and no Intermediate layer. Additionally of the following models are breaking the underlying rule of Staging Models: **NO JOINS** & **NO AGGREGATION / RE-GRAINING**.
- [ ] Handling `conversion_events`:
	- [ ] 1. ADD A `stg_ga4__event_conversions` UPSTREAM INSTEAD OF HAVING BOTH `stg_ga4__page_conversions` AND `stg_ga4__session_conversions`.
	- [ ] 2. MOVE `stg_ga4__page_conversions` --> `int_ga4__page_conversions`, AND PULL FROM `stg_ga4__event_conversions`.
	- [ ] 3. MOVE `stg_ga4__session_conversions` --> `int_ga4__session_conversions`, AND PULL FROM `stg_ga4__event_conversions`.
- [x] Handling `FIRST` & `LAST` events:
	- [x] `stg_ga4__sessions_first_last_pageviews`
	- [x] `stg_ga4__users_first_last_pageviews`
	- [x] `stg_ga4__users_first_last_events`
- [x] Handling `user_properties`:
	- [x] `stg_ga4__users_properties`
	- [x] `stg_ga4__derived_users_properties`
- [x] Handling all `event_*` related models:
	- [x] FIX `stg_ga4__event_page_view`, it is trying to join with something up stream.

### Add Tests & Packages:

- [ ] Testing Packages to use:
	- [ ] [dbt_utils](https://hub.getdbt.com/dbt-labs/dbt_utils/0.1.7/)
	- [ ] [dbt_expectations](https://hub.getdbt.com/calogica/dbt_expectations/0.1.2/)
	- [ ] [dbt_audit_help](https://github.com/dbt-labs/dbt-audit-helper)

### Transition from `dbt Cloud` --> `dbt Core`:

- [ ] A LOT TO DO FOR THIS...

### Add Integration Tests:

- [ ] See the [dbt-ga4 Integration Tests](https://github.com/Velir/dbt-ga4/tree/main/integration_tests) for examples.
	- [ ] See also dbt's docs for [testing a new adapter](https://docs.getdbt.com/docs/contributing/testing-a-new-adapter).

## Other General Issues:

- [ ] Decide on considerations for handling certain `event_params`, such as: 
	- [ ] Google click-related: `gclsrc` and `gclid`.
		- [ ] See [here](https://support.google.com/searchads/answer/7342044) for more info.
	- [ ] Others like: `debug_mode`, `term`, and ?`clean_event`.

# COMPLETED

- [x] Models:
	- [x]
- [x] Macros:
	- [x] `get_position`
		- [x] `get_first`
		- [x] `get_last`
	- [x]
- [x] Metrics:
	- [x]
- [x] Docs:
	- [x]

# OTHER CONSIDERATIONS & IDEAS

- Check [this](https://docs.getdbt.com/docs/building-a-dbt-project/metrics) out.
- IDEALS FOR WHY I AM MAKING SOME OF MY CHOICES REVOLVE AROUND: IMPLICIT VS EXPLICIT
	- TO WRITE ON THIS EXTENSIVELY ONCE PROJECT IS MORE MATURE...
- See this [Stack Overflow Comment](https://stackoverflow.com/questions/64007239/hi-how-do-we-define-select-statement-as-a-variable-in-dbt), as this may be a better way to implement the `unest_params` macro:
	- See also dbt's [Statement Blocks](https://docs.getdbt.com/reference/dbt-jinja-functions/statement-blocks).
```
{%- call statement('my_statement', fetch_result=True) -%}
      SELECT my_field FROM my_table
{%- endcall -%}

{%- set my_var = load_result('my_statement')['data'][0][0] -%}
```
- Consider adding some Metrics / Dimensions for `User-Scoped` illustrating their `most_freq` & `unique_num_of` for the following:
	- `device` & `device_category`, etc.
	- `location`
	- SURE SOME OTHER GREAT ONES, WILL BRAINSTORM / WHITESTORM WITH OTEHRS.
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