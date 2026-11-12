CREATE OR REPLACE VIEW sales AS
SELECT f.*, c.customer_first_name, c.customer_last_name, c.customer_age, c.customer_email, c.customer_country, c.customer_postal_code, c.customer_pet_type, c.customer_pet_name, c.customer_pet_breed, p.product_name, p.product_category, p.product_price, p.product_quantity, p.pet_category, p.product_weight, p.product_color, p.product_size, p.product_brand, p.product_material, p.product_description, p.product_rating, p.product_reviews, p.product_release_date, p.product_expiry_date, st.store_name, st.store_location, st.store_city, st.store_state, st.store_country, st.store_phone, st.store_email, s.supplier_name, s.supplier_contact, s.supplier_email, s.supplier_phone, s.supplier_address, s.supplier_city, s.supplier_country, d.year_key, d.month_key
FROM star.fact_sales f
JOIN star.dim_customer c USING (customer_key)
JOIN star.dim_product p USING (product_key)
JOIN star.dim_store st USING (store_key)
JOIN star.dim_supplier s USING (supplier_key)
JOIN star.dim_date d USING (date_key);
CREATE OR REPLACE VIEW products AS SELECT * FROM star.dim_product;
