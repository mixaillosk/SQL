--Представление "Товары, поставленные в течение последних трёх дней, остаток которых меньше 10% от первоначального количества"
CREATE VIEW products_low_stock AS SELECT * FROM products p
WHERE EXISTS (
    SELECT 1 FROM deliveries d
    WHERE d.product_sku = p.product_sku
        AND d.delivery_date >= CURRENT_DATE - INTERVAL '3 DAYS'
        AND d.remaining_stock < 0.1 * d.quantity
);

SELECT * FROM products_low_stock;

INSERT INTO products (product_sku, product_name, category_name, unit_of_measure, unit_weight, min_store_stock) VALUES
('P004', 'Новый товар', 'Продукты питания', 'шт.', 0.4, 80);
UPDATE deliveries
SET remaining_stock = 5
WHERE product_sku = 'P001';


-- Представление "Общая стоимость остатков товаров"
CREATE VIEW total_stock_value AS SELECT c.category_name AS category, p.product_name,
SUM(d.remaining_stock * d.unit_price) AS total_value FROM products p
JOIN deliveries d ON p.product_sku = d.product_sku
JOIN product_categories c ON p.category_name = c.category_name
GROUP BY c.category_name, p.product_name;

SELECT * FROM total_stock_value;

-- INSERT INTO TotalStockValue (category, productName, totalValue) VALUES --Возникнет ошибка, так как групбай не позволяет напрямую выполнять insert, update, delete + sum
-- ('Продукты питания', 'Новый товар', 1000);
-- UPDATE TotalStockValue -- Аналогично
-- SET totalValue = 2000
-- WHERE productName = 'Хлеб белый';
-- DELETE FROM TotalStockValue -- same
-- WHERE productName = 'Хлеб белый';

--Представление "Остатки тоаров"
CREATE VIEW stock_breakdown AS SELECT
    p.product_sku,
    p.product_name,
    SUM(d.remaining_stock) AS total_stock,
    SUM(CASE WHEN d.delivery_date + c.shelf_life_days > CURRENT_DATE THEN d.remaining_stock ELSE 0 END) AS non_expired_stock,
    SUM(CASE WHEN d.delivery_date + c.shelf_life_days <= CURRENT_DATE THEN d.remaining_stock ELSE 0 END) AS expired_stock
FROM products p
JOIN deliveries d ON p.product_sku = d.product_sku
JOIN product_categories c ON p.category_name = c.category_name
GROUP BY p.product_sku, p.product_name;

SELECT * FROM stock_breakdown;

--Данное представление необноляемо точно так же, как и предыдущее и по тем же причинам