# Project Style Guide
## Overview
...[TO DO]...

## SQL
### Naming Conventions

- All field names should be [snake_cased](https://en.wikipedia.org/wiki/Snake_case):
    ```sql
    -- Preferred
    SELECT
        dvcecreatedtstamp AS device_created_timestamp
        ...

    -- vs

    -- Not Preferred
    SELECT
        dvcecreatedtstamp AS DeviceCreatedTimestamp
        ...

    ```
- Boolean field names should include the `is_` prefix:
    ```sql
    -- Preferred
    SELECT
        deleted AS is_deleted,
        sla     AS has_sla
        ...


    -- vs

    -- Not Preferred
    SELECT
        deleted,
        sla,
        ...

    ```
- Date and Timestamp fields should include the `_date` & `_timestamp` suffix, respectively.
- When joining tables and referencing columns from both tables consider the following:
  - reference the full table name instead of an alias when the table name is shorter, maybe less than 20 characters.  (try to rename the CTE if possible, and lastly consider aliasing to something descriptive)
  - always qualify each column in the SELECT statement with the table name / alias for easy navigation 

    ```sql
    -- Preferred
    SELECT
        budget_forecast_cogs_opex.account_id,
        date_details.fiscal_year,
        date_details.fiscal_quarter,
        date_details.fiscal_quarter_name,
        cost_category.cost_category_level_1,
        cost_category.cost_category_level_2
    FROM budget_forecast_cogs_opex
    LEFT JOIN date_details
        ON date_details.first_day_of_month = budget_forecast_cogs_opex.accounting_period
    LEFT JOIN cost_category
        ON budget_forecast_cogs_opex.unique_account_name = cost_category.unique_account_name

 
    -- vs 

    -- Not Preferred
    SELECT
        a.account_id,
        b.fiscal_year,
        b.fiscal_quarter,
        b.fiscal_quarter_name,
        c.cost_category_level_1,
        c.cost_category_level_2
    FROM budget_forecast_cogs_opex a
    LEFT JOIN date_details b
        ON b.first_day_of_month = a.accounting_period
    LEFT JOIN cost_category c
        ON b.unique_account_name = c.unique_account_name
    ```

### Common Table Expressions (CTEs)

- Prefer CTEs over sub-queries as [CTEs make SQL more readable and are more performant](https://www.alisa-in.tech/post/2019-10-02-ctes/):

    ```sql
    -- Preferred
    WITH important_list AS (

        SELECT DISTINCT
            specific_column
        FROM other_table
        WHERE specific_column != 'foo'
        
    )

    SELECT
        primary_table.column_1,
        primary_table.column_2
    FROM primary_table
    INNER JOIN important_list
        ON primary_table.column_3 = important_list.specific_column

    -- vs   

    -- Not Preferred
    SELECT
        primary_table.column_1,
        primary_table.column_2
    FROM primary_table
    WHERE primary_table.column_3 IN (
        SELECT DISTINCT specific_column 
        FROM other_table 
        WHERE specific_column != 'foo')

    ```

- Use CTEs to reference other tables.
- CTEs should be placed at the top of the query.
- Where performance permits, CTEs should perform a single, logical unit of work.
- CTE names should be as concise as possible while still being clear.
    - Avoid long names like `replace_sfdc_account_id_with_master_record_id` and prefer a shorter name with a comment in the CTE. This will help avoid table aliasing in joins.
- CTEs with confusing or notable logic should be commented in file and documented in dbt docs.
- CTEs that are duplicated across models should be pulled out into their own models.

### Functions

- Prefer `IF()` to a single-line case statement or boolean statement:
    ```sql
    -- Preferred
    SELECT
        IF(event_name = 'page_view', 1, 0) AS is_page_view
        ...

    -- vs   

    -- Not Preferred
    SELECT
        CASE
            WHEN event_name = 'page_view' THEN 1
            ELSE 0
        END AS is_page_view
        ...
    ```
    ```sql
    -- Preferred
    SELECT
        IF(first_page_view_event_key IS NULL, FALSE, TRUE) AS is_entrance
        ...

    -- vs   

    -- Not Preferred
    SELECT
        CASE
            WHEN first_page_view_event_key IS NULL THEN FALSE
            ELSE TRUE
        END AS is_entrance
        ...
    ```

...[TO DO]...

## dbt
...[TO DO]...

## Jinja
...[TO DO]...