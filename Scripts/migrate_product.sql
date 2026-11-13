BEGIN;
DROP VIEW IF EXISTS public.sales;
DROP VIEW IF EXISTS public.products;
CREATE TABLE IF NOT EXISTS star.dim_product_category (
    category_key TEXT PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS star.dim_brand (
    brand_key TEXT PRIMARY KEY,
    brand_name TEXT NOT NULL UNIQUE
);

ALTER TABLE star.dim_product ADD COLUMN IF NOT EXISTS category_key TEXT;
ALTER TABLE star.dim_product ADD COLUMN IF NOT EXISTS brand_key TEXT;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_schema = 'star' AND table_name = 'dim_product'
                 AND column_name = 'product_category') THEN
        INSERT INTO star.dim_product_category (category_key, category_name)
        SELECT DISTINCT encode(sha256(convert_to(product_category, 'UTF8')), 'hex'), product_category
        FROM star.dim_product
        ON CONFLICT DO NOTHING;
        UPDATE star.dim_product
        SET category_key = encode(sha256(convert_to(product_category, 'UTF8')), 'hex');
        ALTER TABLE star.dim_product DROP COLUMN product_category;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_schema = 'star' AND table_name = 'dim_product'
                 AND column_name = 'product_brand') THEN
        INSERT INTO star.dim_brand (brand_key, brand_name)
        SELECT DISTINCT encode(sha256(convert_to(product_brand, 'UTF8')), 'hex'), product_brand
        FROM star.dim_product
        ON CONFLICT DO NOTHING;
        UPDATE star.dim_product
        SET brand_key = encode(sha256(convert_to(product_brand, 'UTF8')), 'hex');
        ALTER TABLE star.dim_product DROP COLUMN product_brand;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'dim_product_category_key_fkey'
                   AND conrelid = 'star.dim_product'::regclass) THEN
        ALTER TABLE star.dim_product ADD CONSTRAINT dim_product_category_key_fkey
            FOREIGN KEY (category_key) REFERENCES star.dim_product_category (category_key);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'dim_product_brand_key_fkey'
                   AND conrelid = 'star.dim_product'::regclass) THEN
        ALTER TABLE star.dim_product ADD CONSTRAINT dim_product_brand_key_fkey
            FOREIGN KEY (brand_key) REFERENCES star.dim_brand (brand_key);
    END IF;
END $$;
ALTER TABLE star.dim_product ALTER COLUMN category_key SET NOT NULL;
ALTER TABLE star.dim_product ALTER COLUMN brand_key SET NOT NULL;
CREATE OR REPLACE VIEW sales AS
SELECT f.*, c.customer_first_name, c.customer_last_name, c.customer_age, c.customer_email, c.customer_country, c.customer_postal_code, c.customer_pet_type, c.customer_pet_name, c.customer_pet_breed, p.product_name, pc.category_name AS product_category, p.product_price, p.product_quantity, p.pet_category, p.product_weight, p.product_color, p.product_size, b.brand_name AS product_brand, p.product_material, p.product_description, p.product_rating, p.product_reviews, p.product_release_date, p.product_expiry_date, st.store_name, st.store_location, st.store_city, st.store_state, st.store_country, st.store_phone, st.store_email, s.supplier_name, s.supplier_contact, s.supplier_email, s.supplier_phone, s.supplier_address, s.supplier_city, s.supplier_country, d.year_key, d.month_key
FROM star.fact_sales f
JOIN star.dim_customer c USING (customer_key)
JOIN star.dim_product p USING (product_key)
JOIN star.dim_product_category pc USING (category_key)
JOIN star.dim_brand b USING (brand_key)
JOIN star.dim_store st USING (store_key)
JOIN star.dim_supplier s USING (supplier_key)
JOIN star.dim_date d USING (date_key);
CREATE OR REPLACE VIEW products AS
SELECT p.*, pc.category_name AS product_category, b.brand_name AS product_brand
FROM star.dim_product p
JOIN star.dim_product_category pc USING (category_key)
JOIN star.dim_brand b USING (brand_key);
COMMIT;
