# SOURCES
{% docs events %}
Main events table composed of the exported GA4 day sharded event tables (event_YYYMMDD).
{% enddocs %}

{% docs events_intraday %}
Intraday events table which is optionally exported by GA4. Always contains events from the current day.
{% enddocs %}

# MODELS
{% docs base_ga4__events %}
Base events model that pulls all fields from raw data. Resulting table is partitioned on event_date and is useful in that BQ queries can be cached against this table, but not against wildcard searches from the original tables which are sharded on date. Some light transformation and renaming beyond the base events model. Adds surrogate keys for sessions and events.
{% enddocs %}

{% docs base_ga4__events_intraday %}
Base model for intraday events that will be unioned to the past events stored in the incremental model.
{% enddocs %}

{% docs stg_ga4__query_params %}
This model pivots the query string parameters contained within the event's page_location field to become rows. Each row is a single parameter/value combination contained in a single event's query string.
{% enddocs %}

{% docs stg_ga4__events %}
Staging model that contains window functions used to generate unique keys.
{% enddocs %}

{% docs stg_ga4__items %}
Flattens out the 'items' field for e-commerce events such as purchase and add_to_cart.
{% enddocs %}

{% docs stg_ga4__traffic_sources %}
Unnests source, medium and name from the traffic_sources nested field, and adds a default_channel_grouping based off those fields.
{% enddocs %}

{% docs ga4__events %}
This is the table for event-level dimensions & metrics. ...TO ADD A BETTER DESCRIPTION...
{% enddocs %}

{% docs ga4__pages %}
This is the table for page-level dimensions & metrics, such as `page_views`, `exits`, and `total_engagement_duration`. This table is grouped by `page_title`, `event_date`, and `page_location`.
{% enddocs %}

{% docs ga4__sessions %}
This is the  table for session-level dimensions & metrics, such as `sessions_engaged`, `engagement_duration`, and `page_views`. This table is grouped by both `session_key` and `user_key`.
{% enddocs %}

{% docs ga4__users %}
This is the table for user-level dimensions & metrics, such as `first` & `last_seen_date`, `geo`, and `traffic_source`. This table is grouped by the hashed `user_key` dimension, which is based on `user_id`, or `user_pseudo_id` if one doesn't exist.
{% enddocs %}

# MACROS
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

# METRICS
-- CHANGE TO SPECIFY BETWEEN METRICS & DIMENSIONS --

{% docs user_key %} A hashed primary key for each user, which is based on `user_id`, or `user_pseudo_id` if one doesn't exist. {% enddocs %}

{% docs first_seen_timestamp %} Timestamp of when a user was first seen, measured via their first interaction or session_start. {% enddocs %}

{% docs first_seen_date %} Date of when a user was first seen, measured via their first interaction or session_start. {% enddocs %}

{% docs last_seen_timestamp %} Timestamp of when a user was last seen, measured via their last interaction or session_start. {% enddocs %}

{% docs last_seen_date %} Date of when a user was last seen, measured via their last interaction or session_start. {% enddocs %}

{% docs sessions %} The number of sessions that began on your website or application. {% enddocs %}

{% docs page_views %} The number of mobile app screens or web pages a user saw. Repeated views of a single screen or page are counted. {% enddocs %}

{% docs purchases %} The total number of purchases on your website or application for a user. {% enddocs %}

-- GEO --
{% docs continent %} The continent from which user activity originated. For example, if someone visits your websites from the United States, the text `Americas` populates the dimension. {% enddocs %}

{% docs sub_continent %} The subcontinent from which user activity originated. For example, if someone visits your website from the United States, the text `Northern America` populates the dimension. {% enddocs %}

{% docs country %} The country from which user activity originated. For example, if someone visits your website from the United States, the text `United States` populates the dimension. {% enddocs %}

{% docs region %} The geographic region from which user activity originated. For example, if someone visits your website from New York City, the text `New York` populates the dimension. If someone visits your website from England, the text `England` populates the dimension. {% enddocs %}

{% docs city %} The city from which user activity originates. For example, if someone visits your website from New York City, the text `New York` populates the dimension. {% enddocs %}
---------------------

## DEVICE
{% docs category %} The type of device from which user activity originated. Device categories include `desktop`, `mobile`, and `tablet`. {% enddocs %}

{% docs mobile_brand_name %} The brand name of the mobile device (e.g., Motorola, LG, or Samsung). {% enddocs %}

{% docs mobile_model_name %} The device model name (e.g., iPhone 5s or SM-J500M). {% enddocs %}

{% docs mobile_marketing_name %}  {% enddocs %}

{% docs mobile_os_hardware_model %}  {% enddocs %}

{% docs operating_system %} The operating system used by visitors on your website or application. Typical operating systems include `Android`, `Chrome OS`, `Macintosh`, and `Windows`. {% enddocs %}

{% docs operating_system_version %} The operating system version used by visitors on your website or application. (e.g., `9.3.2` or `5.1.1`). {% enddocs %}

{% docs vendor_id %}  {% enddocs %}

{% docs advertising_id %}  {% enddocs %}

{% docs language %} The name of the language of a user's browser or device (e.g., `French`, `English`). {% enddocs %}

{% docs is_limiting_ad_tracking %}  {% enddocs %}

{% docs time_zone_offset_seconds %}  {% enddocs %}

{% docs browser %} The browser from which user activity originated. Typical browsers include `Chrome`, `Edge`, `Firefox`, `Internet Explorer`, `Opera`, and `Safari`. {% enddocs %}

{% docs browser_version %} The version of the browser from which user activity originated. For example, the browser version might be `96.0.4664.110`. {% enddocs %}
---------------------

## TRAFFIC SOURCE
{% docs medium %} The medium by which the user was first acquired. {% enddocs %}

{% docs name %}  {% enddocs %}

{% docs source %} The source by which the user was first acquired. {% enddocs %}
--------------------

{% docs first_page_location %} The complete URL of the webpage that a user visited first on your website. For example, if someone visits www.googlemerchandisestore.com/Bags?theme=1, then the complete URL will populate the dimension. {% enddocs %}

{% docs first_page_hostname %} The subdomain and domain names of the URL that a user visited first on your website. For example, the hostname of `www.example.com/contact.html` is `www.example.com`. {% enddocs %}

{% docs first_page_referrer %} The first referring URL, which is the user's previous URL and can be your website's domain or other domains. {% enddocs %}

{% docs last_page_location %} The complete URL of the webpage that a user visited last on your website. For example, if someone visits www.googlemerchandisestore.com/Bags?theme=1, then the complete URL will populate the dimension. {% enddocs %}

{% docs last_page_hostname %} The subdomain and domain names of the URL that a user visited last on your website. For example, the hostname of `www.example.com/contact.html` is `www.example.com`. {% enddocs %}

{% docs last_page_referrer %} The last referring URL, which is the user's previous URL and can be your website's domain or other domains. {% enddocs %}

{% docs session_key %} A hashed primary key for each session, which is a combination of `stream_id`, `ga_session_id`, and `user_key`. {% enddocs %}

{% docs ga_session_number %} Identifies the number of sessions that a user has started up to the current session (e.g., a user's third or fifth session on your site). {% enddocs %}

{% docs landing_page %} The page path and query string associated with the first pageview in a session. {% enddocs %}

{% docs landing_page_hostname %} The subdomain and domain name of the URL associated with the first pageview in a session. For example, the hostname of `www.example.com/contact.html` is `www.example.com`. {% enddocs %}

{% docs row_num %} An aded row number used to identify the first session_start event and to remove theduplicates. {% enddocs %}

{% docs default_channel_grouping %} The default channel grouping that was associated with the start of a session. {% enddocs %}

{% docs session_start_date %} Date of when the session started. {% enddocs %}

{% docs session_start_timestamp %} Timestamp of when the session started. {% enddocs %}

{% docs sum_event_value %} The sum of all monetary value parameters supplied with an event for a session. You can use this context-sensitive metric to capture data that's important to you (e.g. `revenue`, `time`, `distance`). {% enddocs %}

{% docs session_engaged %} Whether or not (i.e., `1` or `0`) a session lasted 10 seconds or longer, or had 1 or more conversion events, or 2 or more page or screen views. {% enddocs %}

{% docs event_date %} Date of when the associated page was viewed. {% enddocs %}

{% docs hour %} Hour of when the associated page was viewed. {% enddocs %}

{% docs page_location %} The complete URL of the webpage that a user visited on your website. For example, if someone visits www.googlemerchandisestore.com/Bags?theme=1, then the complete URL will populate the dimension. {% enddocs %}

{% docs page_title %} The page title that you set on your website. {% enddocs %}

{% docs users %} The number of unique users who triggered a page view. {% enddocs %}

{% docs new_users %} The number of unique users with 0 previous sessions, who triggered a page view. Users who already have had a session are returning users. {% enddocs %}

{% docs entrances %} The number of times that the first event recorded for a session occurred on a page or screen. {% enddocs %}

{% docs exits %} The number of times that the last event recorded for a session occurred on a page or screen. {% enddocs %}

{% docs total_engagement_duration %} The total duration of time each page was viewed. {% enddocs %}

{% docs scroll_events %} The number of times a user reaches the bottom of each page (i.e., when a 90% vertical depth becomes visible). {% enddocs %}

{% docs event_key %} A hashed primary key for each event, which is a combination of `event_number`, `session_key`, and `user_key`. {% enddocs %}

{% docs event_timestamp %} Timestamp of when the associated event was viewed. {% enddocs %}

{% docs event_name %} The name of the event. {% enddocs %}

{% docs event_previous_timestamp %} The time (in microseconds, UTC) at which the event was previously logged on the client. {% enddocs %}

{% docs event_value %} The currency-converted value (in USD) of the event's "value" parameter. {% enddocs %}

{% docs event_bundle_sequence_id %} The sequential ID of the bundle in which these events were uploaded. {% enddocs %}

{% docs event_server_timestamp_offset %} Timestamp offset between collection time and upload time in micros. {% enddocs %}

{% docs page_referrer %} The first referring URL, which is the user's previous URL and can be your website's domain or other domains. {% enddocs %}

## ITEMS
{% docs item_id %} The ID of the item. {% enddocs %}

{% docs item_name %} The name of the item. {% enddocs %}

{% docs item_brand %} The brand of the item. {% enddocs %}

{% docs item_variant %} The variant of the item. {% enddocs %}

{% docs item_category %} The category of the item. {% enddocs %}

{% docs item_category2 %} The sub category of the item. {% enddocs %}

{% docs item_category3 %} The sub category of the item. {% enddocs %}

{% docs item_category4 %} The sub category of the item. {% enddocs %}

{% docs item_category5 %} The sub category of the item. {% enddocs %}

{% docs price_in_usd %} The price of the item, in USD with standard unit. {% enddocs %}

{% docs price %} The price of the item in local currency. {% enddocs %}

{% docs quantity %} The quantity of the item. {% enddocs %}

{% docs item_revenue_in_usd %} The revenue of this item, calculated as price_in_usd * quantity. It is populated for purchase events only, in USD with standard unit. {% enddocs %}

{% docs item_revenue %} The revenue of this item, calculated as price * quantity. It is populated for purchase events only, in local currency with standard unit. {% enddocs %}

{% docs item_refund_in_usd %} The refund value of this item, calculated as price_in_usd * quantity. It is populated for refund events only, in USD with standard unit. {% enddocs %}

{% docs item_refund %} The refund value of this item, calculated as price * quantity. It is populated for refund events only, in local currency with standard unit. {% enddocs %}

{% docs coupon %} Coupon code applied to this item. {% enddocs %}

{% docs affiliation %} A product affiliation to designate a supplying company or brick and mortar store location. {% enddocs %}

{% docs location_id %} The location associated with the item. {% enddocs %}

{% docs item_list_id %} The ID of the list in which the item was presented to the user. {% enddocs %}

{% docs item_list_name %} The name of the list in which the item was presented to the user. {% enddocs %}

{% docs item_list_index %} The position of the item in a list. {% enddocs %}

{% docs promotion_id %} The ID of a product promotion. {% enddocs %}

{% docs promotion_name %} The name of a product promotion. {% enddocs %}

{% docs creative_name %} The name of a creative used in a promotional spot. {% enddocs %}

{% docs creative_slot %} The name of a creative slot. {% enddocs %}
---------------------


---------------------
## MISC. [...TO DO...]
---------------------

{% docs user_id %} The user ID set via the setUserId API. {% enddocs %}

{% docs user_pseudo_id %} The pseudonymous id (e.g., app instance ID) for the user. {% enddocs %}

{% docs user_first_touch_timestamp %} The time (in microseconds) at which the user first opened the app or visited the site. {% enddocs %}

{% docs stream_id %} The numeric ID of the stream. {% enddocs %}

{% docs platform %} The platform on which the app was built. {% enddocs %}

{% docs ads_storage %} Whether ad targeting is enabled for a user. Possible values: `Yes`, `No`, or `Unset`. {% enddocs %}

{% docs analytics_storage %} Whether Analytics storage is enabled for the user. Possible values: `Yes`, `No`, or `Unset`. {% enddocs %}

{% docs uses_transient_token %} Whether a web user has denied Analytics storage and the developer has enabled measurement without cookies based on transient tokens in server data. Possible values: `Yes`, `No`, or `Unset`. {% enddocs %}

{% docs user_ltv %} A record of Lifetime Value information about the user. {% enddocs %}

{% docs revenue %} The Lifetime Value (revenue) of the user. {% enddocs %}

{% docs currency %} The Lifetime Value (currency) of the user. This field is not populated in intraday tables. {% enddocs %}