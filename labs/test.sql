-- CREATE TABLE price_changes (
--     change_date DATE NOT NULL,
--     category_name VARCHAR(100) NOT NULL,
--     product_sku VARCHAR(8) NOT NULL,
--     product_name VARCHAR(100) NOT NULL,
--     unit_of_measure VARCHAR(20) NOT NULL,
--     remaining_stock NUMERIC(7, 2) NOT NULL,
--     old_price NUMERIC(8, 2) NOT NULL,
--     new_price NUMERIC(8, 2) NOT NULL
-- );

CREATE OR REPLACE PROCEDURE generate_price_change_report(mode INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    new_price NUMERIC(8, 2);
BEGIN
    -- Очистка таблицы при mode = 0
    IF mode = 0 THEN
        DELETE FROM price_changes;
    END IF;

    -- Обработка данных
    FOR rec IN (
        SELECT 
            d.product_sku,
            p.product_name,
            c.category_name,
            p.unit_of_measure,
            d.remaining_stock,
            d.unit_price,
            d.delivery_date,
            c.shelf_life_days
        FROM deliveries d
        JOIN products p ON d.product_sku = p.product_sku
        JOIN product_categories c ON p.category_name = c.category_name
        WHERE d.remaining_stock > 0
    ) LOOP
        -- Вызов функции calculate_new_price
        new_price := calculate_new_price(
            rec.unit_price,
            rec.delivery_date,
            rec.shelf_life_days
        );

        -- Добавление записи только если цена изменилась
        IF new_price < rec.unit_price THEN
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
                new_price
            );
        END IF;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ошибка при формировании отчета: %', SQLERRM;
END;
$$;

CALL price_change_rep(0);

CALL price_change_rep(1);
SELECT * FROM price_changes;