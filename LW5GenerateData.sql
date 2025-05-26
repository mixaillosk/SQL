TRUNCATE TABLE deliveries;
TRUNCATE TABLE suppliers CASCADE;
TRUNCATE TABLE products CASCADE;
TRUNCATE TABLE product_categories CASCADE;
-- TRUNCATE TABLE price_changes CASCADE;
-- TRUNCATE TABLE orders CASCADE;


INSERT INTO suppliers (id, supplier_name, address)
SELECT 
    i,
    'Поставщик ' || i,
    'Адрес ' || i
FROM generate_series(1, 20) AS i;


INSERT INTO product_categories (category_name, shelf_life_days) VALUES
    ('Мебель', 700),
    ('Обувь', 200),
    ('Продукты питания', 10),
    ('Спортивные товары', 100),
    ('Текстиль', 150),
    ('Хозяйственные товары', 100),
    ('Электроника', 900);


CREATE TEMP TABLE temp_products (
    product_sku TEXT PRIMARY KEY,
    product_name TEXT,
    category_name TEXT,
    unit_of_measure TEXT,
    unit_weight NUMERIC,
    min_store_stock NUMERIC
);

INSERT INTO temp_products (product_sku, product_name, category_name, unit_of_measure, unit_weight, min_store_stock)
SELECT 
    'P' || LPAD(i::TEXT, 4, '0') AS product_sku,
    'Товар ' || i % 280 AS product_name,
    CASE 
        WHEN i % 7 = 0 THEN 'Мебель'
        WHEN i % 7 = 1 THEN 'Обувь'
        WHEN i % 7 = 2 THEN 'Продукты питания'
        WHEN i % 7 = 3 THEN 'Спортивные товары'
        WHEN i % 7 = 4 THEN 'Текстиль'
        WHEN i % 7 = 5 THEN 'Хозяйственные товары'
        ELSE 'Электроника'
    END AS category_name,
    CASE 
        WHEN i % 2 = 0 THEN 'шт.'
        ELSE 'кг'
    END AS unit_of_measure,
    ROUND((RANDOM() * 10)::NUMERIC, 2) AS unit_weight,
    FLOOR(RANDOM(1, 10) * 10)::NUMERIC AS min_store_stock
FROM generate_series(1, 10000) AS i
ON CONFLICT (product_sku) DO NOTHING;


-- Проверяем уникальность product_sku перед вставкой
INSERT INTO products (product_sku, product_name, category_name, unit_of_measure, unit_weight, min_store_stock)
SELECT 
    t.product_sku,
    t.product_name,
    t.category_name,
    t.unit_of_measure,
    t.unit_weight,
    t.min_store_stock
FROM temp_products t
WHERE NOT EXISTS (
    SELECT 1 
    FROM products p 
    WHERE p.product_sku = t.product_sku
);
DROP TABLE temp_products;


INSERT INTO deliveries (delivery_id, supplier_id, product_sku, quantity, unit_price, delivery_date, remaining_stock)
SELECT 
    i,
    FLOOR(RANDOM() * 10) + 1,
    (ARRAY(SELECT product_sku FROM products ORDER BY RANDOM()))[1 + MOD(i, (SELECT COUNT(*) FROM products))],
    ROUND((RANDOM(1, 10) * 100)::NUMERIC, 2),
    ROUND((RANDOM(1, 10) * 100)::NUMERIC, 2),
    CURRENT_DATE - INTERVAL '1 day' * FLOOR(RANDOM(10, 100)/10 * 365),
    1
FROM generate_series(1, 1000) AS i;

UPDATE deliveries
SET remaining_stock = FLOOR(RANDOM() * (quantity + 1))::INT::NUMERIC(7, 2) * CASE WHEN RANDOM() < 0.5 THEN 0 ELSE 1 END;