CREATE OR REPLACE FUNCTION calculate_new_price(price NUMERIC(8, 2) DEFAULT 0, delivery_date DATE DEFAULT NULL, shelf_life_days INT DEFAULT 0) RETURNS NUMERIC(8, 2) AS $$
DECLARE
	days_left INT;
	discount NUMERIC(8, 2);
BEGIN
	IF price <= 0 OR delivery_date IS NULL OR shelf_life_days <= 0 THEN
        RETURN -1;
    END IF;
	
	days_left := shelf_life_days - (CURRENT_DATE - delivery_date);

	IF days_left < 1 THEN discount := LEAST(price * 0.2, 50);
	ELSIF days_left < 3 THEN discount := LEAST(price * 0.2, 50);
	ELSE discount := 0;
	END IF;

	RETURN price - discount;
END;
$$ LANGUAGE plpgsql;


SELECT calculate_new_price(100, '2023-10-25', 5);
SELECT calculate_new_price(-100, '2023-10-25', 5);
SELECT calculate_new_price(100, NULL, 5);

--Формирование строки 'n str'

CREATE OR REPLACE FUNCTION format_quantity(n NUMErIC DEFAULT 0, unit VARCHAR DEFAULT '') RETURNS VARCHAR AS $$
BEGIN
    IF n <= 0 OR unit = '' ThEN RETURN '#########';
    END IF;

    IF unit <> 'кг' AND n <> FLOOR(n) THEN RETURN '#########';
    END IF;

    RETURN TRIM(TO_CHAR(n, '999999999.99')) || ' ' || unit;
END;
$$ LANGUAGE plpgsql;

SELECT format_quantity(2.4, 'кг');

SELECT format_quantity(-5, 'шт.');

SELECT format_quantity(2.5, 'шт.');


--Слздание отчёта об изменении цен

CREATE TABLE price_changes (
    change_date DATE NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    product_sku VARCHAR(8) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    unit_of_measure VARCHAR(20) NOT NULL,
    remaining_stock NUMERIC(7, 2) NOT NULL,
    old_price NUMERIC(8, 2) NOT NULL,
    new_price NUMERIC(8, 2) NOT NULL
);


CREATE OR REPLACE PROCEDURE price_change_rep(mode INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
BEGIN
    IF mode = 0 THEN
        DELETE FROM price_changes;
    END IF;

    BEGIN
        FOR rec IN (
            SELECT 
                p.product_sku,
                p.product_name,
                p.category_name,
                p.unit_of_measure,
                d.remaining_stock,
                d.unit_price,
                c.shelf_life_days,
                d.delivery_date
            FROM products p
            JOIN deliveries d ON p.product_sku = d.product_sku
            JOIN product_categories c ON p.category_name = c.category_name
        ) LOOP
            INSERT INTO price_changes (
                change_date,
                category_name,
                product_sku,
                product_name,
                unit_of_measure,
                remaining_stock,
                old_price,
                new_price
            ) VALUES (
                CURRENT_DATE,
                rec.category_name,
                rec.product_sku,
                rec.product_name,
                rec.unit_of_measure,
                rec.remaining_stock,
                rec.unit_price,
                calculate_new_price(rec.unit_price, rec.delivery_date, rec.shelf_life_days)
            );
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Ошибка при обработке данных: %', SQLERRM;
    END;
END;
$$;


CALL price_change_rep(0);

CALL price_change_rep(1);
SELECT * FROM price_changes;


--Формирование заказов на товары

CREATE TABLE orders (
    order_number NUMERIC(6, 0) PRIMARY KEY,
    order_date DATE NOT NULL,
    supplier_id NUMERIC(6, 0) NOT NULL REFERENCES suppliers(id),
    product_sku VARCHAR(8) NOT NULL REFERENCES products(product_sku),
    product_name VARCHAR(100) NOT NULL,
    unit_of_measure VARCHAR(20) NOT NULL,
    quantity NUMERIC(7, 2) NOT NULL CHECK (quantity > 0)
);

DROP PROCEDURE IF EXISTS create_order(integer);

CREATE OR REPLACE PROCEDURE create_order(N INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    current_order_number NUMERIC(6, 0);
    existing_order RECORD;
BEGIN
    IF N <= 1 THEN
        RAISE EXCEPTION 'Параметр N должен быть больше 1';
    END IF;

    FOR rec IN (
        SELECT 
            p.product_sku,
            p.product_name,
            p.unit_of_measure,
            p.min_store_stock,
            SUM(d.remaining_stock) AS total_remaining
        FROM products p
        LEFT JOIN deliveries d ON p.product_sku = d.product_sku
        GROUP BY p.product_sku, p.product_name, p.unit_of_measure, p.min_store_stock
        HAVING SUM(d.remaining_stock) < p.min_store_stock
    ) LOOP
        SELECT supplier_id INTO existing_order
        FROM deliveries
        WHERE product_sku = rec.product_sku
        ORDER BY delivery_date DESC
        LIMIT 1;

        IF NOT FOUND THEN
            RAISE NOTICE 'Нет поставок для товара %. Заказ не может быть оформлен.', rec.product_sku;
            CONTINUE;
        END IF;

        SELECT order_number INTO current_order_number
        FROM orders
        WHERE supplier_id = existing_order.supplier_id
          AND order_date = CURRENT_DATE
          AND product_sku = rec.product_sku;

        IF NOT FOUND THEN
            SELECT COALESCE(MAX(order_number), 0) + 1 INTO current_order_number FROM orders;

            INSERT INTO orders (
                order_number,
                order_date,
                supplier_id,
                product_sku,
                product_name,
                unit_of_measure,
                quantity
            ) VALUES (
                current_order_number,
                CURRENT_DATE,
                existing_order.supplier_id,
                rec.product_sku,
                rec.product_name,
                rec.unit_of_measure,
                N * rec.min_store_stock
            );
        END IF;

        UPDATE orders
        SET quantity = N * rec.min_store_stock
        WHERE order_number = current_order_number
          AND product_sku = rec.product_sku;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при формировании заказа: %', SQLERRM;
END;
$$;

CALL create_order(2);
SELECT * FROM orders