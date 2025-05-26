CREATE TABLE suppliers (--Поставщики
    id NUMERIC(6, 0) PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL
);

CREATE TABLE product_categories (--Категории товаров
    category_name VARCHAR(100) PRIMARY KEY,
    shelf_life_days INT NOT NULL
);

CREATE TABLE products (--Товары
    product_sku VARCHAR(8) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_name VARCHAR(100) NOT NULL REFERENCES product_categories,
    unit_of_measure VARCHAR(20) NOT NULL,
    unit_weight NUMERIC(5, 2) NOT NULL,
    min_store_stock NUMERIC(4, 0) NOT NULL
);

CREATE TABLE deliveries (--Поставки
    delivery_id NUMERIC(6, 0) PRIMARY KEY,
    supplier_id NUMERIC(6, 0) NOT NULL REFERENCES suppliers,
    product_sku VARCHAR(8) NOT NULL REFERENCES products,
    quantity NUMERIC(7, 2) NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(8, 2) NOT NULL CHECK (unit_price > 0),
    delivery_date DATE NOT NULL,
    remaining_stock NUMERIC(7, 2) NOT NULL CHECK (remaining_stock >= 0 AND remaining_stock <= quantity)
);