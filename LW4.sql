CREATE TABLE products_extra (
    product_sku VARCHAR(8) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_name VARCHAR(100) NOT NULL REFERENCES product_categories(category_name),
    unit_of_measure VARCHAR(50) NOT NULL,
    unit_weight NUMERIC(5, 2) NOT NULL,
    min_store_stock NUMERIC(4, 0) NOT NULL
);

INSERT INTO products_extra (product_sku, product_name, category_name, unit_of_measure, unit_weight, min_store_stock)
VALUES
    ('P001', 'Хлеб белый', 'Продукты питания', 'шт.', 0.5, 100),
    ('H001', 'Универсальная губка', 'Хозяйственные товары', 'шт.', 0.1, 200),
    ('T002', 'Футболка женская', 'Текстиль', 'шт.', 0.4, 200),
    ('E002', 'Мышь компьютерная', 'Электроника', 'шт.', 0.1, 5),
	('E003', 'Мышь компьютерная', 'Электроника', 'шт.', 0.1, 5);

--проекция (project)
SELECT product_sku, product_name FROM products;

--селекция (select)
SELECT * FROM products
WHERE category_name = 'Продукты питания';

--Декартово произведение (cartesian product)
SELECT P.product_sku, P.product_name, S.supplier_name FROM products P, suppliers S;

-- объединение (union)
SELECT * FROM products UNION SELECT * FROM products_extra;

--разность (except)
SELECT P.* FROM products P
LEFT JOIN products_extra PE ON P.product_sku = PE.product_sku
WHERE PE.product_sku IS NULL;

--пересечение (intersect)
SELECT P.* FROM products P
JOIN products_extra PE ON P.product_sku = PE.product_sku;

--соединение (join)
SELECT P.product_sku, P.product_name, D.quantity, D.remaining_stock FROM products P
INNER JOIN deliveries D ON P.product_sku = D.product_sku
WHERE D.remaining_stock > 0;

--деление (division)
SELECT DISTINCT P.category_name FROM products P
WHERE NOT EXISTS (
	SELECT 1 FROM products_extra PE WHERE NOT EXISTS (
		SELECT 1 FROM products P2
		WHERE P2.category_name = P.category_name
		AND P2.product_sku = PE.product_sku
	)
);