WITH base AS (

    SELECT
        *
    FROM
        {{ ref('stg_ga4__events') }}

),

unnest_items AS (

    SELECT
        event_key,

        items.item_id                                           AS item_id,
        items.item_name                                         AS item_name,
        items.item_brand                                        AS item_brand,
        items.item_variant                                      AS item_variant,
        items.item_category                                     AS item_category,
        items.item_category2                                    AS item_category2,
        items.item_category3                                    AS item_category3,
        items.item_category4                                    AS item_category4,
        items.item_category5                                    AS item_category5,
        COALESCE(items.price_in_usd, items.price)               AS price,
        items.quantity                                          AS quantity,
        COALESCE(items.item_revenue_in_usd, items.item_revenue) AS item_revenue,
        COALESCE(items.item_refund_in_usd, items.item_refund)   AS item_refund,
        items.coupon                                            AS coupon,
        items.affiliation                                       AS affiliation,
        items.location_id                                       AS location_id,
        items.item_list_id                                      AS item_list_id,
        items.item_list_name                                    AS item_list_name,
        items.item_list_index                                   AS item_list_index,
        items.promotion_id                                      AS promotion_id,
        items.promotion_name                                    AS promotion_name,
        items.creative_name                                     AS creative_name,
        items.creative_slot                                     AS creative_slot
    FROM
        base,
        UNNEST(items) AS items

)

SELECT * FROM unnest_items