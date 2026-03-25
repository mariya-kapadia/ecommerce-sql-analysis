CREATE TABLE customers (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);


CREATE TABLE orders (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TEXT,
    order_approved_at TEXT,
    order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT
);


CREATE TABLE order_items (
    order_id TEXT,
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,
    price REAL,
    freight_value REAL
);


CREATE TABLE products (
    product_id TEXT,
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g REAL,
    product_length_cm REAL,
    product_height_cm REAL,
    product_width_cm REAL
);



CREATE TABLE payments (
    order_id TEXT,
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value REAL
);




SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM payments;



SELECT * FROM customers LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM order_items LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM payments LIMIT 5;



SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM payments;


SELECT DISTINCT order_status FROM orders;
SELECT DISTINCT product_category_name FROM products;


SELECT 
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM orders;


SELECT COUNT(DISTINCT order_id) FROM orders;
SELECT COUNT(DISTINCT customer_unique_id) FROM customers;


SELECT SUM(payment_value) AS total_revenue
FROM payments;


SELECT 
    c.customer_unique_id,
    ROUND(SUM(p.payment_value), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;


SELECT 
    o.product_id,
    p.product_category_name,
    COUNT(*) AS total_orders
FROM order_items o
JOIN products p ON o.product_id = p.product_id
GROUP BY o.product_id, p.product_category_name
ORDER BY total_orders DESC
LIMIT 10;


SELECT 
    pr.product_category_name,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN products pr ON oi.product_id = pr.product_id
GROUP BY pr.product_category_name
ORDER BY total_revenue DESC;


SELECT 
    strftime('%Y-%m', order_purchase_timestamp) AS month,
    ROUND(SUM(p.payment_value), 2) AS monthly_revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;


SELECT 
    ROUND(SUM(payment_value) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM payments;


SELECT 
    customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY customer_unique_id;


SELECT 
    customer_unique_id,
    total_spent
FROM (
    SELECT 
        c.customer_unique_id,
        SUM(p.payment_value) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
)
WHERE total_spent > (
    SELECT AVG(payment_value) FROM payments
)
ORDER BY total_spent DESC;


SELECT 
    customer_unique_id,
    SUM(payment_value) AS total_spent,
    RANK() OVER (ORDER BY SUM(payment_value) DESC) AS rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY customer_unique_id
LIMIT 10;


SELECT 
    strftime('%Y-%m', o.order_purchase_timestamp) AS month,
    SUM(p.payment_value) AS monthly_revenue,
    SUM(SUM(p.payment_value)) OVER (
        ORDER BY strftime('%Y-%m', o.order_purchase_timestamp)
    ) AS running_total
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY month;


SELECT *
FROM (
    SELECT 
        p.product_category_name,
        oi.product_id,
        COUNT(*) AS total_orders,
        RANK() OVER (
            PARTITION BY p.product_category_name 
            ORDER BY COUNT(*) DESC
        ) AS rank
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name, oi.product_id
)
WHERE rank = 1;


SELECT 
    COUNT(*) AS repeat_customers
FROM (
    SELECT 
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
WHERE total_orders > 1;