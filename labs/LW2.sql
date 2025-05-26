-- Поставщики, чьи товары в данное время есть в магазине
-- 1 вариант
SELECT DISTINCT s.supplier_name FROM suppliers s
JOIN deliveries d ON s.id = d.supplier_id
WHERE d.remaining_stock > 70;

-- 2 вариант
SELECT DISTINCT supplier_name FROM suppliers
WHERE id IN (
    SELECT supplier_id
    FROM deliveries
    WHERE remaining_stock > 0
);

-- Поставки товаров, срок реализации которых подошёл к концу
SELECT 
    d.delivery_id,
    d.supplier_id,
    d.product_sku,
    d.quantity,
    d.unit_price,
    d.delivery_date,
    (d.delivery_date + INTERVAL '1 day' * c.shelf_life_days) AS expiration_date
FROM deliveries d
JOIN products p ON d.product_sku = p.product_sku
JOIN product_categories c ON p.category_name = c.category_name
WHERE d.delivery_date <= CURRENT_DATE - c.shelf_life_days
  AND d.remaining_stock > 0;

-- Общий вес товара по всем поставкам
SELECT p.product_sku, p.product_name, SUM(d.quantity * p.unit_weight) AS common_weight 
FROM deliveries d
JOIN products p ON d.product_sku = p.product_sku
GROUP BY p.product_sku, p.product_name;

-- Товары, чей суммарный остаток меньше установленного минимума
SELECT 
    p.product_sku, 
    p.product_name, 
    SUM(d.remaining_stock) AS summary_remaining 
FROM deliveries d
JOIN products p ON d.product_sku = p.product_sku
-- WHERE p.min_store_stock < 100
GROUP BY p.product_sku, p.product_name
HAVING SUM(d.remaining_stock) < p.min_store_stock;

-- Поставщики, от которых нет поставок за последние 30 дней
SELECT s.supplier_name FROM suppliers s
WHERE NOT EXISTS (
    SELECT 1 
    FROM deliveries d
    WHERE d.supplier_id = s.id 
      AND d.delivery_date >= CURRENT_DATE - INTERVAL '30 days'
);