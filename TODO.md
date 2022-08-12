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


## Metrics & Dimensions to add:
- [User Lifetime](https://support.google.com/analytics/answer/9143382) Metrics:
	- `lifetime_engaged_sessions`: The number of engaged sessions a user had since they first visited your website or application.
	- `lifetime_engagemenet_duration`:The length of time since a user's first visit that the user was active on your website or application while it was in the foreground.
	- `lifetime_session_duration`: The total duration of user sessions, from their first session until the current session expires, including time when your website or application is in the background.
	- `lifetime_ad_revenue`: The ad revenue you generate from someone since their first visit to your website or app.
	- `LTV` or `lifetime_value`: 	Lifetime value (LTV) shows the total revenue from purchases on your website or application. You can use the data to determine how valuable users are based on additional revenue you generate.
	- `lifetime_sessions`: ALREADY HAVE THIS - `sessions` @ User Level
	- `lifetime_transactions` ALREADY HAVE THIS - `purchases` @ User Level
- ...WAY MORE...