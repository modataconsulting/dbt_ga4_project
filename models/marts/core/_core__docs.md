{% docs dim_ga4__users %}

This is the Dimension Table for user-level Dimensions, such as `first` & `last_seen_date`, `geo`, and `traffic_source`. This table is grouped by the hashed `user_key` dimension, which is based on `user_id`, or `user_pseudo_id` if one doesn't exist.

{% enddocs %}


{% docs dim_ga4__sessions %}

This is the dimension table for session-level dimensions, such as `landing_page`, `device`, and campaign-related attributes.

{% enddocs %}


{% docs fct_ga4__pages %}

This is the Fact Table for page-related Metrics, such as `page_views`, `exits`, and `time_on_page`. This table is grouped by `page_title`, `event_date`, and `page_location`.

{% enddocs %}


{% docs fct_ga4__sessions %}

This is the fact table for session-level metrics, such as `sessions_engaged`, `engagement_time`, and `page_views`. This table is grouped by both `session_key` and `user_key`.

{% enddocs %}


{% docs ga4__events %}

This is the table for event-level metrics & dimensions. TO ADD A BETTER DESCRIPTION.

{% enddocs %}