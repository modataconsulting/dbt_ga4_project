# dbt GA4 Project

First and foremost, this project is foundational based off of the dbt [GA4 Package by Velir](https://hub.getdbt.com/velir/ga4/latest), but has been modified and refactored for internal purposes.

[...INTRO...]

This project the [Google Analytics 4 BigQuery Exports](https://support.google.com/analytics/answer/7029846?hl=en&ref_topic=9359001) as its base dataset, and offers useful base transformations to provide report-ready dimension & fact models that can be used for reporting purposes, blending with other data, and/or for ML models.

# Models

| model | description |
|-------|-------------|
| stg_ga4__events | Contains cleaned event data that is enhanced with useful event and session keys. |
| stg_ga4__event_* | 1 model per event (ex: page_view, purchase) which flattens event parameters specific to that event. |
| stg_ga4__event_items | Contains item data associated with e-commerce events. (Purchase, add to cart, etc.) |
| stg_ga4__event_to_query_string_params | Mapping between each event and any query parameters & values that were contained in the event's `page_location` field. |
| stg_ga4__user_properties | Finds the most recent occurance of specified user_properties for each user. |
| stg_ga4__derived_user_properties | Finds the most recent occurance of specific event_params and assigns them to a user's user_key. Derived user properties are specified as variables. (see documentation below) |
| stg_ga4__session_conversions | Produces session-grouped event counts for a configurable list of event names. (see documentation below) |
| stg_ga4__sessions_traffic_sources | Finds the first source, medium, campaign and default channel grouping for each session. |
| dim_ga4__users | Dimension table for users which contains attributes such as first and last page viewed. Unique on `user_key` which is a hash of the `user_id` if it exists, otherwise it falls back to the `user_pseudo_id`.| 
| dim_ga4__sessions | Dimension table for sessions which contains useful attributes such as geography, device information, and campaign data. |
| fct_ga4__pages | Fact table for pages which aggregates common page metrics by page_location, date, and hour. |
| fct_ga4__sessions | Fact table for session metrics including session_engaged, sum_engagement_time_msecs, and others. |

# Seeds

| seed file | description |
|-----------|-------------|
| ga4_source_categories.csv| Google's mapping between `source` and `source_category`. Downloaded from https://support.google.com/analytics/answer/9756891?hl=en |

Make sure to run `dbt seed` before running `dbt run`.

## Style Guide:
This project and any future projects that may be based off of this intial `dbt_ga4_project`, will be following [This Project's Style Guide...IN PROGRESS](), which borrows ideals from the following Style Guides:
- [dbt's Style Guide](https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md)
- [GitLab's SQL Style Guide](https://about.gitlab.com/handbook/business-technology/data-team/platform/sql-style-guide)

# Installation & Configuration
## Setup

## Required Variables

This package assumes that you have an existing DBT project with a BigQuery profile and a BigQuery GCP instance available with GA4 event data loaded. Source data is located using the following variables which must be set in your `dbt_project.yml` file.

```
vars:
    ga4:
        project: "<gcp_project>" # Set your Project ID here.
        dataset: "<ga4_dataset>" # Set your Dataset name here.
        start_date: "YYYYMMDD"   # Set the start date that you want to retrieve data from.
        frequency: "daily"       # daily|streaming|daily+streaming Match to the type of export configured in GA4; daily+streaming appends today's intraday data to daily data.
```

If you don't have any GA4 data of your own, you can connect to Google's public data set with the following settings:

```
vars:
    project: "bigquery-public-data"
    dataset: "ga4_obfuscated_sample_ecommerce"
    start_date: "20210120"
```

Find more info about the GA4 obfuscated dataset [here](https://support.google.com/analytics/answer/10937659?hl=en#zippy=%2Cin-this-article). 

## Optional Variables

### Query Parameter Exclusions

Setting `query_parameter_exclusions` will remove query string parameters from the `page_location` field for all downstream processing. Original parameters are captured in a new `original_page_location` field. Ex:

```
vars:
  ga4: 
    query_parameter_exclusions: ["gclid","fbclid","_ga"] 
```
### Custom Parameters

Within GA4, you can add custom parameters to any event. These custom parameters will be picked up by this package if they are defined as variables within your `dbt_project.yml` file using the following syntax:

```
[event name]_custom_parameters
  - name: "[name of custom parameter]"
    value_type: "[string_value|int_value|float_value|double_value]"
```

For example: 

```
vars:
  ga4:
    page_view_custom_parameters:
          - name: "clean_event"
            value_type: "string_value"
          - name: "country_code"
            value_type: "int_value"
```
### User Properties

User properties are provided by GA4 in the `user_properties` repeated field. The most recent user property for each user will be extracted and included in the `dim_ga4__users` model by configuring the `user_properties` variable in your project as follows:

```
vars:
  ga4:
    user_properties:
      - user_property_name: "membership_level"
        value_type: "int_value"
      - user_property_name: "account_status"
        value_type: "string_value"
```

### Derived User Properties

Derived user properties are different from "User Properties" in that they are derived from event parameters. This provides additional flexibility in allowing users to turn any event parameter into a user property. 

Derived User Properties are included in the `dim_ga4__users` model and contain the latest event parameter value per user. 

```
derived_user_properties:
  - event_parameter: "[your event parameter]"
    user_property_name: "[a unique name for the derived user property]"
    value_type: "[string_value|int_value|float_value|double_value]"
```

For example: 

```
vars:
  ga4:
      derived_user_properties:
        - event_parameter: "page_location"
          user_property_name: "most_recent_page_location"  
          value_type: "string_value"
        - event_parameter: "another_event_param"
          user_property_name: "most_recent_param"  
          value_type: "string_value"
```
### GA4 Recommended Events

See the README file at /dbt_packages/models/staging/ga4/recommended_events for instructions on enabling [Google's recommended events](https://support.google.com/analytics/answer/9267735?hl=en).

### Conversion Events

Specific event names can be specified as conversions by setting the `conversion_events` variable in your `dbt_project.yml` file. These events will be counted against each session and included in the `fct_sessions.sql` dimensional model. Ex:

```
vars:
  ga4:
      conversion_events:['purchase','download']
```

## Resources:
- GA4 Resources:
    - [GA4 BigQuery Export schema](https://support.google.com/analytics/answer/7029846?hl=en&ref_topic=9359001)
- BigQuery Resources:
    - [BigQuery Docs](https://cloud.google.com/bigquery/docs)
    - [BigQuery: Functions, Operators, and Conditionals](https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators)
- dbt Resources:
    - [Getting Started with dbt Cloud](https://docs.getdbt.com/guides/getting-started)
        - [Getting Started with dbt Core](https://docs.getdbt.com/guides/getting-started/learning-more/getting-started-dbt-core)
        - [Refactoring legacy SQL to dbt](https://docs.getdbt.com/guides/getting-started/learning-more/refactoring-legacy-sql)
    - [Best Practices](https://docs.getdbt.com/guides/best-practices)
- Jinja Resources:
    - [Jinja Template Designer Documentation](https://jinja.palletsprojects.com/en/3.1.x/templates)
- Project References:
    - [GA4 dbt Package](https://github.com/Velir/dbt-ga4.git)
    - [Stacktonic dbt Example Project](https://github.com/stacktonic-com/stacktonic-dbt-example-project)
- [SQL Formatter](https://smalldev.tools/sql-formatter-online)