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

-- DEVICE --
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

-- TRAFFIC SOURCE --
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

{% docs sum_event_value_in_usd %} The sum of all monetary value parameters supplied with an event for a session. You can use this context-sensitive metric to capture data that's important to you (e.g. `revenue`, `time`, `distance`). {% enddocs %}

{% docs session_engaged %} Whether or not (1 or 0) a session lasted 10 seconds or longer, or had 1 or more conversion events, or 2 or more page or screen views. {% enddocs %}

{% docs event_date %} Date of when the associated page was viewed. {% enddocs %}

{% docs hour %} Hour of when the associated page was viewed. {% enddocs %}

{% docs page_location %} The complete URL of the webpage that a user visited on your website. For example, if someone visits www.googlemerchandisestore.com/Bags?theme=1, then the complete URL will populate the dimension. {% enddocs %}

{% docs page_title %} The page title that you set on your website. {% enddocs %}

{% docs users %} The number of unique users who triggered a page view. {% enddocs %}

{% docs new_users %} The number of unique users with 0 previous sessions, who triggered a page view. Users who already have had a session are returning users. {% enddocs %}

{% docs entrances %} The number of times that the first event recorded for a session occurred on a page or screen. {% enddocs %}

{% docs exits %} The number of times that the last event recorded for a session occurred on a page or screen. {% enddocs %}

{% docs time_on_page %} The total duration of time each page was viewed. {% enddocs %}

{% docs scroll_events %} The number of times a user reaches the bottom of each page (i.e., when a 90% vertical depth becomes visible). {% enddocs %}