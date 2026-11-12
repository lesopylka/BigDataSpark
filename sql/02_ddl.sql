CREATE SCHEMA IF NOT EXISTS star;
CREATE TABLE star.dim_customer (
    customer_key TEXT PRIMARY KEY,
    customer_first_name TEXT NOT NULL,
    customer_last_name TEXT NOT NULL,
    customer_age TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_country TEXT NOT NULL,
    customer_postal_code TEXT NOT NULL,
    customer_pet_type TEXT NOT NULL,
    customer_pet_name TEXT NOT NULL,
    customer_pet_breed TEXT NOT NULL
);
CREATE TABLE star.dim_seller (
    seller_key TEXT PRIMARY KEY,
    seller_first_name TEXT NOT NULL,
    seller_last_name TEXT NOT NULL,
    seller_email TEXT NOT NULL,
    seller_country TEXT NOT NULL,
    seller_postal_code TEXT NOT NULL
);
CREATE TABLE star.dim_product (
    product_key TEXT PRIMARY KEY,
    product_name TEXT NOT NULL,
    product_category TEXT NOT NULL,
    product_price TEXT NOT NULL,
    product_quantity TEXT NOT NULL,
    pet_category TEXT NOT NULL,
    product_weight TEXT NOT NULL,
    product_color TEXT NOT NULL,
    product_size TEXT NOT NULL,
    product_brand TEXT NOT NULL,
    product_material TEXT NOT NULL,
    product_description TEXT NOT NULL,
    product_rating TEXT NOT NULL,
    product_reviews TEXT NOT NULL,
    product_release_date TEXT NOT NULL,
    product_expiry_date TEXT NOT NULL
);
CREATE TABLE star.dim_store (
    store_key TEXT PRIMARY KEY,
    store_name TEXT NOT NULL,
    store_location TEXT NOT NULL,
    store_city TEXT NOT NULL,
    store_state TEXT NOT NULL,
    store_country TEXT NOT NULL,
    store_phone TEXT NOT NULL,
    store_email TEXT NOT NULL
);
CREATE TABLE star.dim_supplier (
    supplier_key TEXT PRIMARY KEY,
    supplier_name TEXT NOT NULL,
    supplier_contact TEXT NOT NULL,
    supplier_email TEXT NOT NULL,
    supplier_phone TEXT NOT NULL,
    supplier_address TEXT NOT NULL,
    supplier_city TEXT NOT NULL,
    supplier_country TEXT NOT NULL
);
CREATE TABLE star.dim_date (
    date_key TEXT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year_key TEXT NOT NULL,
    month_key TEXT NOT NULL
);
CREATE TABLE star.fact_sales (
    sale_key TEXT PRIMARY KEY,
    source_file TEXT NOT NULL,
    source_id INTEGER NOT NULL,
    customer_key TEXT NOT NULL REFERENCES star.dim_customer,
    seller_key TEXT NOT NULL REFERENCES star.dim_seller,
    product_key TEXT NOT NULL REFERENCES star.dim_product,
    store_key TEXT NOT NULL REFERENCES star.dim_store,
    supplier_key TEXT NOT NULL REFERENCES star.dim_supplier,
    date_key TEXT NOT NULL REFERENCES star.dim_date,
    sale_quantity INTEGER NOT NULL CHECK (sale_quantity > 0),
    sale_total_price NUMERIC(18, 2) NOT NULL CHECK (sale_total_price >= 0)
);
