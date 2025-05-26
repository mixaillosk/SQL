CREATE INDEX idx_deliveries_product_sku ON Deliveries(product_sku);
CREATE INDEX idx_deliveries_supplier ON Deliveries(supplier_ID);
CREATE INDEX idx_deliveries_supplier_stock ON deliveries(supplier_id, remaining_stock); --+++
CREATE INDEX idx_deliveries_stock ON Deliveries(remaining_Stock);
CREATE INDEX idx_deliveries_product_date ON deliveries(delivery_date, product_sku); --+++
CREATE INDEX idx_deliveries_product_date_stock_quantity ON deliveries(product_sku, delivery_date, remaining_stock, quantity);
CREATE INDEX idx_deliveries_date ON Deliveries(delivery_Date); --+++
CREATE INDEX idx_deliveries_sku_stock ON deliveries(product_sku, remaining_stock);

CREATE INDEX idx_categories_category ON Product_Categories(category_Name);
CREATE INDEX idx_categories_life ON Product_Categories(shelf_Life_Days);


CREATE INDEX idx_products_sku ON Products(product_SKU);
CREATE INDEX idx_products_category ON Products(category_Name);
CREATE INDEX idx_products_name ON Products(product_Name);
CREATE INDEX idx_products_sku_name ON Products(product_sku, product_name);
CREATE INDEX idx_products_sku_category ON Products(product_sku, category_name);
CREATE INDEX idx_products_sku_weight ON Products(product_sku, unit_weight);
CREATE INDEX idx_products_sku_min_stock ON Products(product_sku, min_store_stock);
CREATE INDEX idx_products_min_stock ON Products(min_store_stock);

CREATE INDEX idx_categories_name_shelf_life ON Product_Categories(category_name, shelf_life_days);

-----------drop------------
DROP INDEX idx_suppliers_id;

DROP INDEX idx_deliveries_product_sku;
DROP INDEX idx_deliveries_supplier;
DROP INDEX idx_deliveries_supplier_stock;
DROP INDEX idx_deliveries_stock;
DROP INDEX idx_deliveries_product_date;
DROP INDEX idx_deliveries_product_date_stock_quantity;
DROP INDEX idx_deliveries_date;
DROP INDEX idx_deliveries_sku_stock;

DROP INDEX idx_categories_category;
DROP INDEX idx_categories_life;

DROP INDEX idx_products_sku;
DROP INDEX idx_products_category;
DROP INDEX idx_products_name;
DROP INDEX idx_products_sku_name;
DROP INDEX idx_products_sku_category;
DROP INDEX idx_products_sku_weight;
DROP INDEX idx_products_sku_min_stock;
DROP INDEX idx_products_min_stock;

DROP INDEX idx_categories_name_shelf_life;