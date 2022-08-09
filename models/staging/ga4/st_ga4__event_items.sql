-- INCLUDE DESCRIPTION HERE TO DESCRIBE FILE --

WITH items_with_params AS (

    SELECT
        event_key,
        event_name,
        items.item_id,
        items.item_name,
        items.item_brand,
        items.item_variant,
        items.item_category,
        items.item_category2,
        items.item_category3,
        items.item_category4,
        items.item_category5,
        items.price_in_usd,
        items.price,
        items.quantity,
        items.item_revenue_in_usd,
        items.item_revenue,
        items.item_refund_in_usd,
        items.item_refund,
        items.coupon,
        items.affiliation,
        items.location_id,
        items.item_list_id,
        items.item_list_name,
        items.item_list_index,
        items.promotion_id,
        items.promotion_name,
        items.creative_name,
        items.creative_slot
    FROM
        {{ ref('stg_ga4__events') }},
        UNNEST(items) AS items
    WHERE
        event_name IN (
            'add_payment_info',
            'add_shipping_info',
            'add_to_cart',
            'add_to_wishlist',
            'begin_checkout',
            'purchase',
            'refund',
            'remove_from_cart',
            'select_item',
            'select_promotion',
            'view_item_list',
            'view_promotion'
        )

)

SELECT * FROM items_with_params