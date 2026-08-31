-- ============================================================
-- Amazon_order — Tableau Dashboard Query Recap (MySQL)
-- ============================================================
-- These queries reproduce the data behind each chart in the two
-- BIA project dashboards. Column names below are inferred from
-- t
-- Assumed columns on Amazon_order:
--   order_id                (order identifier)
--   order_date              (date the order was placed)
--   ship_date               (date the order was shipped)
--   customer_name           (Arun / Punitha / Srinidhi / Sruti)
--   payment_instrument_type (Visa / MasterCard / Gift Certificate/Card / Cash On Delivery)
--   shipping_charge         (numeric amount charged for shipping, 0 if none)
--   total_owed              (total order value)
--   total_discount          (discount amount applied to the order)
--   product_name            (product purchased)
-- ============================================================


-- ============================================================
-- DASHBOARD 1
-- ============================================================

-- Chart: Unique Order Addresses (donut)
-- Distinct order count per named order address / customer.
SELECT
    customer_name AS order_address,
    COUNT(DISTINCT order_id) AS unique_orders
FROM Amazon_order
GROUP BY customer_name;


-- Chart: Payment Options (bar) — "Payment Instrument Type (group)"
-- Count of orders per payment method: Visa, Gift Certificate/Card,
-- MasterCard, Cash On Delivery.
SELECT
    payment_instrument_type,
    COUNT(order_id) AS count_of_order_id
FROM Amazon_order
GROUP BY payment_instrument_type
ORDER BY count_of_order_id DESC;


-- Chart: Shipping Charges (Yes/No pie)
-- Whether an order incurred a shipping charge.
-- If Amazon_order already has a Yes/No column for this, skip the
-- CASE and GROUP BY that column directly instead.
SELECT
    CASE WHEN shipping_charge > 0 THEN 'Yes' ELSE 'No' END AS shipping_charges,
    COUNT(order_id) AS order_count
FROM Amazon_order
GROUP BY CASE WHEN shipping_charge > 0 THEN 'Yes' ELSE 'No' END;


-- Chart: Order vs Shipping (scatter)
-- Row-level calculated field, not an aggregation: number of days
-- between order date and ship date ("New date difference"),
-- plotted against ship date.
-- MySQL's DATEDIFF(a, b) returns (a - b) in days.
SELECT
    order_id,
    ship_date,
    DATEDIFF(ship_date, order_date) AS new_date_difference
FROM Amazon_order;


-- ============================================================
-- DASHBOARD 2
-- ============================================================

-- Chart: Total spend throughout the years (line)
SELECT
    YEAR(order_date) AS year_of_order_date,
    SUM(total_owed) AS total_owed
FROM Amazon_order
GROUP BY YEAR(order_date)
ORDER BY year_of_order_date;


-- Chart: Total Discounts throughout the years (area)
SELECT
    YEAR(order_date) AS year_of_order_date,
    SUM(total_discount) AS sum_of_total_discounts
FROM Amazon_order
GROUP BY YEAR(order_date)
ORDER BY year_of_order_date;


-- Chart: Highest Discounts (top 10 products by discount)
SELECT
    product_name,
    SUM(total_discount) AS sum_of_total_discounts
FROM Amazon_order
GROUP BY product_name
ORDER BY sum_of_total_discounts DESC
LIMIT 10;
