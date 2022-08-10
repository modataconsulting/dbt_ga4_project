USAGE EXAMPLE:

-------------------

{% docs macro_name_here %}
This macro is designed to collect the masking policies of a model or source table.  It can be used for a single table or for an entire resource type.


It can take 2 parameters:
* `resource_type`: the dbt resource type to get he masking policies for. Acceptable values are `source` and `model`
* `table`: Optional, the name of the dbt object to retrieve the policy information for.


Output:

* A list of dictionaries with the elements of a fully qualified column name and the masking policy for that column.

{% enddocs %}

-------------------

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