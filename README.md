***NOTE: This project is still very much a work in progress, with much of the larger model restructuring still to come, see the [TODO](/TODO.md) file for more info.***

# dbt GA4 Project
First and foremost, this project is based off of the dbt [GA4 Package by Velir](https://hub.getdbt.com/velir/ga4/latest), but has been modified and refactored for internal purposes.

This project uses [Google Analytics 4 BigQuery Exports](https://support.google.com/analytics/topic/9359001) as its source data, and offers useful base transformations to provide report-ready dimension & fact models that can be used for reporting purposes, blending with other data, and/or feature engineering for ML models.

Find more info about Google Analytics 4 BigQuery Exports [here](https://developers.google.com/analytics/bigquery).

**Features Overview:**
- Four final tables--`ga4__events`, `ga4__pages`, `ga4__sesssions`, and `ga4__users`--that are completed unnested to be wide & denomalized for easy querying by the end-user.
- Conversion of the the day-shared `events_YYYYMMDD` & `events_intraday_YYYYMMDD` tables into singular date-partitionioned incremental base models.
- Extracted URL `query_params`, such as `gclid`, `fbclid`, other UTMs.
- Custom `Variables`. See [here](#optional-variables) for more info.
- Custom `Marcros`. See [here](#macros) for more info.

## Style Guide:
This project and any future projects that may be based off of this intial `dbt_ga4_project`, will be following [This Project's Style Guide...IN PROGRESS](/STYLEGUIDE.md), which borrows ideals from the following Style Guides:
- [dbt's Style Guide](https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md)
- [GitLab's SQL Style Guide](https://about.gitlab.com/handbook/business-technology/data-team/platform/sql-style-guide)

# Models

<p align="center"><b><i>
DAG Overview<br>
NOTE: This DAG Image is NOT current & will continue to CHANGE until all models are finalized.
</b></i></p>

![DAG Overview](assets/DAG.png)

## Mart Models
| Model Name | Description |
|------------|-------------|
| ga4__events | This is the table for event-level metrics & dimensions, that has been transformed to be wide & denomalized for easier quering. |
| ga4__pages | This is the table for page-level metrics & dimensions, such as `page_views`, `exits`, and `users`. This table is grouped by `page_title`, `event_date`, and `page_path`. |
| ga4__sessions | This is the table for session-level metrics & dimensions, such as `is_engaged_session`, `engagement_duration`, and `page_views`. This table is grouped by both `session_key` and `user_key`. |
| ga4__users | This is the table for user-level metrics & dimensions, such as `first` & `last_seen_date`, `geo`, and `traffic_source`. This table is grouped by the hashed `user_key` dimension, which is based on `user_id`, or `user_pseudo_id` if one doesn't exist. |

## Staging Models
| Model Name | Description |
|------------|-------------|
| stg_ga4__events | Creates a table with event data that is enhanced with useful `event_keys`, `page_keys`, `session keys`, and `user_keys`. |
| stg_ga4__event_params | Creates a table that unnests all of the event parameters specific to each event (e.g. `page_view`, `click`, or `scroll`), except for those marked in the `dbt_project.yml` file. |
| stg_ga4__traffic_sources | Creates a table that designates a `default_channel_grouping` via the `source`, `medium`, `campaign` columns. |
| stg_ga4__user_props | Creates a table that unnests the `user_properties`, except for those marked in the `dbt_project.yml` file. |
| stg_ga4__query_params | Maps any and all query parameters (e.g. `gclid`, `fbclid`, etc.) contained in each event's `page_location`. |
| stg_ga4__conversions | Creates a table for the events that you mark as a `conversion_event` in the `dbt_project.yml` file. |

## Intermediate Models
| Model Name | Description |
|------------|-------------|
| int_ga4__events_joined | ...[TO DO]... |
| int_ga4__pages_grouped | ...[TO DO]... |
| int_ga4__sessions_grouped | ...[TO DO]... |
| int_ga4__users_grouped | ...[TO DO]... |

# Macros
***NOTE: These Macros are also not finalized & are likely to change.***

### get_first(`by_column_name`,`from_column_name`) *[source](macros/get_positions.sql)*
This macro returns the `FIRST` position of a specified `from_column_name`, which is partioned by the `by_column_name`.

**Args:**
- `by_column_name` (required): The name of the column which you want to partition your selction by.
- `from_column_name` (required): The name of the column to get the first value of. 

**Usage:**
```sql
{{ get_first('<by_column_name>', '<from_column_name>') }}
```

**Example:** Get the landing_page of a corresponding Session by selecting the first `page_path` using that Session's `session_key`.
```sql
SELECT
  {{ get_first('session_key', 'page_path') }} AS landing_page
  ...
```

### get_last(`by_column_name`,`from_column_name`) *[source](macros/get_positions.sql)*
This macro returns the `LAST` position of a specified `from_column_name`, which is partioned by the `by_column_name`.

**Args:**
- `by_column_name` (required): The name of the column which you want to partition your selction by.
- `from_column_name` (required): The name of the column to get the last value of. 

**Usage:**
```sql
{{ get_last('<by_column_name>', '<from_column_name>') }}
```

**Example:** Get the last `event_key` for a corresponding Session using that Session's `session_key`.
```sql
SELECT
  {{ get_last('session_key', 'event_key') }} AS last_session_event_key,
  ...
```

### extract_hostname_from_url(`url`) *[source](macros/parse_url.sql)*
This macro extracts the `hostname` from a column containing a `url`.

**Args:**
- `url` (required): The column containting URLs.

**Usage:**
```sql
{{ extract_hostname_from_url('<url>') }}
```

**Example:** Extract the `hostname` from the `page_location` column.
```sql
SELECT
  {{ extract_hostname_from_url('page_location') }} AS page_hostname,
  ...
```

### extract_query_string_from_url(`url`) *[source](macros/parse_url.sql)*
This macro extracts the `query_string` from a column containing a `url`.

**Args:**
- `url` (required): The column containting URLs.

**Usage:**
```sql
{{ extract_query_string_from_url('<url>') }}
```

**Example:** Extract the `query_string` from the `page_location` column.
```sql
SELECT
  {{ extract_query_string_from_url('page_location') }} AS page_query_string,
  ...
```

### remove_query_parameters(`url`, `[parameters]`) *[source](macros/parse_url.sql)*
This macro removes the specified `parameters` from a column containing a `url`.

**Args:**
- `url` (required): The column containting URLs.
- `parameters` (required, default=`[]`): A list of query parameters to remove from the URL.

**Usage:**
```sql
{{ remove_query_parameters('<url>', '[parameters]')  }}
```

**Example:** Remove the parameters: `gclid`, `fbclid`, and `_ga` from the `page_location` column.
```sql
{% set parameters = ['gclid','fbclid','_ga'] %}

SELECT
  {{ remove_query_parameters('page_location', parameters) }} AS clean_page_location,
  ...
```

### unnest_by_key(`column_to_unnest`, `key_to_extract`, `value_type` = "string") *[source](macros/unnest_by_keys.sql)*
This macro unnests a single key's value from an array. This macro will dynamically alias the sub-query with the name of the `column_to_unnest`.

**Args:**
- `column_to_unnest` (required): The array column to unnest the key's value from.
- `key_to_extract` (required): The key by which to get the corresponding value for.
- `value_type` (optional, default="string"): The data type of the key's value column.

**Usage:**
```sql
{{ unnest_by_key('<column_to_unnest>', '<key_to_extract>', '<value_type>') }}
```

**Example:** Unnest the corresponding values for the keys: `page_location` and `ga_session_number` from the nested `event_params` column.
```sql
SELECT
  -- Unnest the default STRING value type
  {{ unnest_by_key('event_params', 'page_location') }},
  -- Unnest the INT value type
  {{ unnest_by_key('event_params', 'ga_session_number',  'int') }},
  ...
```

### unnest_by_key_alt(`column_to_unnest`, `key_to_extract`, `value_type` = "string") *[source](macros/unnest_by_keys.sql)*
This macro unnests a single key's value from an array. This macro allows for a custom alias named sub-query.

**Args:**
- `column_to_unnest` (required): The array column to unnest the key's value from.
- `key_to_extract` (required): The key by which to get the corresponding value for.
- `value_type` (optional, default="string"): The data type of the key's value column.

**Usage:**
```sql
{{ unnest_by_key_alt('<column_to_unnest>', '<key_to_extract>', '<value_type>') }} AS <custom_alias_name>,
```

**Example:** Unnest the corresponding values for the keys: `page_location` and `ga_session_number` from the nested `event_params` column. 
```sql
SELECT
  -- Unnest the default STRING value type & use a custom alias
  {{ unnest_by_key_alt('event_params', 'page_location') }} AS url, 
  -- Unnest the INT value type & use a custom alias
  {{ unnest_by_key_alt('event_params', 'ga_session_number',  'int') }} AS session_number,
  ...
```

### get_event_params() *[source](macros/unnest_by_keys.sql)*
This macro will dynamically return all of the `keys` and their corresponding `value_types` found in the `event_params` array column.
- This macro will exclude event_params added to the `excluded_event_params` variable, which is specified in the `dbt_project.yml` file.

**Usage / Example:**
```sql
SELECT
  {% for event_param in get_event_params() -%}

  {{ unnest_by_key('event_params', event_param['event_param_key'], event_param['event_param_value']) }}
    
  {{- "," if not loop.last }}
  {% endfor %}
  ...
```

### default_channel_grouping(`source`, `medium`, `source_category`) *[source](macros/default_channel_groupings.sql)*
This macro determines the `default_channel_grouping` and will result in one the following classifications: 
- `Direct`
- `Paid Social`
- `Oraginc Social`
- `Email`
- `Affiliates`
- `Paid Shopping`
- `Paid Search`
- `Display`
- `Other Advertising`
- `Organic Search`
- `Organic Video`
- `Organic Shopping`
- `Audio`
- `SMS`
- `(Other)`

**Args:**
- `source` (required): The source column used in determining the default channel grouping.
- `medium` (required): The medium column used in determining the default channel grouping.
- `source_category` (required): The source category column used in determining the default channel grouping. These are desiganted in the `ga4_source_categories.csv` seed file.

**Usage:**
```sql
{{ default_channel_grouping('<source>', '<medium>', '<source_category>') }}
```

**Example:** 
```sql
SELECT
  {{ default_channel_grouping('source', 'medium', 'source_category') }} AS default_channel_grouping,
  ...
```

# Seeds
| Seed File | Description |
|-----------|-------------|
| ga4_source_categories.csv| Google's mapping between `source` and `source_category`. More info and the download can be found [here](https://support.google.com/analytics/answer/9756891?hl=en). |

Make sure to run `dbt seed` before running `dbt run`.

# Installation & Configuration
## Setup
...[TO DO]...

## Required Variables
This package assumes that you have an existing DBT project with a BigQuery profile and a BigQuery GCP instance available with GA4 event data loaded. Source data is located using the following variables which must be set in your `dbt_project.yml` file.
```yaml
vars:
  project: '<gcp_project>' # Set your Project ID here.
  dataset: '<ga4_dataset>' # Set your Dataset name here.
  start_date: 'YYYYMMDD'   # Set the start date that you want to retrieve data from.
  frequency: 'daily'       # daily|streaming|daily+streaming Match to the type of export configured in GA4; daily+streaming appends today's intraday data to daily data.
```

If you don't have any GA4 data of your own, you can connect to Google's public data set with the following settings:
```yaml
vars:
  project: 'bigquery-public-data'
  dataset: 'ga4_obfuscated_sample_ecommerce'
  start_date: '20210120'
```
Find more info about the GA4 obfuscated dataset [here](https://developers.google.com/analytics/bigquery/web-ecommerce-demo-dataset). 

## Optional Variables
***NOTE: These Variables are also NOT finalized & are LIKELY to change.***

### Query Parameter Exclusions
Setting any `query_parameter_exclusions` will remove query string parameters from the `page_location` field for all downstream processing. Original parameters are captured in a new `original_page_location` field. Ex:
```yaml
vars: 
  query_parameter_exclusions: ['gclid','fbclid','_ga'] 
```

### Conversion Events
Specific event names can be specified as conversions by setting the `conversion_events` variable in your `dbt_project.yml` file. These events will be counted against each session and included in the `fct_sessions.sql` dimensional model. Ex:
```yaml
vars:
  conversion_events:['purchase','download']
```

## Resources & References:
- GA4 Resources:
  - [GA4 BigQuery Export schema](https://support.google.com/analytics/answer/7029846?hl=en&ref_topic=9359001)
  - [Intro To GA4 in BQ](https://www.ga4bigquery.com/introduction-to-google-analytics-4-ga4-export-data-in-bigquery/)
- SQL & BigQuery Resources:
  - [BigQuery Docs](https://cloud.google.com/bigquery/docs)
  - [BigQuery: Functions, Operators, and Conditionals](https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators)
  - [BigQuery: Query Syntax](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax)
  - [BigQuery: Best Practices](https://cloud.google.com/bigquery/docs/best-practices-performance-overview)
  - [SQL Formatter](https://smalldev.tools/sql-formatter-online)
- dbt Resources:
  - [Getting Started with dbt Cloud](https://docs.getdbt.com/guides/getting-started)
    - [Getting Started with dbt Core](https://docs.getdbt.com/guides/getting-started/learning-more/getting-started-dbt-core)
    - [Refactoring legacy SQL to dbt](https://docs.getdbt.com/guides/getting-started/learning-more/refactoring-legacy-sql)
  - [Best Practices](https://docs.getdbt.com/guides/best-practices)
  - [GitLab's dbt Guide](https://about.gitlab.com/handbook/business-technology/data-team/platform/dbt-guide/)
  - [Jinja Template Designer Documentation](https://jinja.palletsprojects.com/en/3.1.x/templates)
- Project References:
  - [GA4 dbt Package](https://github.com/Velir/dbt-ga4.git)
  - [Stacktonic dbt Example Project](https://github.com/stacktonic-com/stacktonic-dbt-example-project)
  - Also inspired by [this](https://github.com/llooker/ga_four_block_dev/blob/master/views/sessions.view.lkml)
