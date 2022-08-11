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
	- ?count_page_views
	- ?sum_event_value_in_usd
	- ?session_engaged --> **OR** engaged_session?