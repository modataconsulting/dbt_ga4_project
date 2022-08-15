{% docs default_channel_groupings %}

This macro determines the `default_channel_grouping` dimension based on following: 
* `source`, 
* `medium`, and 
* `source_category` -- which is desiganted in the `ga4_source_categories.csv` seed file.

The resulting `default_channel_grouping` will be one of the following:
* `Direct`
* `Paid Social`
* `Oraginc Social`
* `Email`
* `Affiliates`
* `Paid Shopping`
* `Paid Search`
* `Display`
* `Other Advertising`
* `Organic Search`
* `Organic Video`
* `Organic Shopping`
* `Audio`
* `SMS`
* `(Other)`

{% enddocs %}


{% docs get_position %}

This macro returns either the `FIRST` or `LAST` position of a specified `from_column_name`, which is partioned by the `by_column_name`.

{% enddocs %}


{% docs get_first %}

This macro returns the `FIRST` position of a specified `from_column_name`, which is partioned by the `by_column_name`.

{% enddocs %}


{% docs get_last %}

This macro returns  the `LAST` position of a specified `from_column_name`, which is partioned by the `by_column_name`.

{% enddocs %}


{% docs stage_custom_parameters %}

This macro stages any `custom_parameters` that you specify in the `dbt_project.yml` file, for the purpose of including them in the final `dim_ga4_users` table.

{% enddocs %}


{% docs unnest_by_key %}

This macro unnests the specified `key_to_extract` from the `column_to_unnest`, and may require the additional `value_type` parameter:
* The `value_type` will default a `string`, but may require either a `int` or `float` value_type.

{% enddocs %}


{% docs extract_hostname_from_url %}

This macro extracts the `hostname` from the `URL`.

{% enddocs %}


{% docs extract_query_string_from_url %}

This macro extracts the `query_parameters` from the `URL`.

{% enddocs %}


{% docs remove_query_parameters %}

This macro will remove any `query_parameters` from the `URL` that you specify in the `dbt_project.yml` file.

{% enddocs %}