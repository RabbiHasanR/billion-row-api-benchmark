-- Create customers table
CREATE TABLE IF NOT EXISTS customers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    price NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create purchases table
CREATE TABLE IF NOT EXISTS purchases (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT REFERENCES customers(id),
    product_id BIGINT REFERENCES products(id),
    quantity INT NOT NULL,
    total_price NUMERIC(12,2),
    purchase_time TIMESTAMP DEFAULT NOW(),
    region VARCHAR(100),
    payment_mode VARCHAR(50),
    status VARCHAR(50)
);




-- use indexing in purchases table for optimize performance
-- CREATE INDEX idx_purchases_region_purchase_time_desc
-- ON purchases (region, purchase_time DESC);

-- CREATE INDEX IF NOT EXISTS idx_purchases_purchase_time_desc ON purchases (purchase_time DESC);

-- Optional if you're filtering often by region
-- CREATE INDEX idx_purchases_purchase_time_desc ON purchases (purchase_time DESC);

-- CREATE INDEX IF NOT EXISTS idx_purchases_customer_id ON purchases (customer_id);
-- CREATE INDEX IF NOT EXISTS idx_purchases_product_id ON purchases (product_id);





CREATE OR REPLACE FUNCTION migrate_purchases()
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    BEGIN
        -- Step 1: Rename old purchases table to backup
        EXECUTE 'ALTER TABLE purchases RENAME TO purchases_backup';

        -- Step 2: Create new partitioned purchases table
        EXECUTE '
            CREATE TABLE IF NOT EXISTS purchases (
                id BIGSERIAL,
                customer_id BIGINT REFERENCES customers(id),
                product_id BIGINT REFERENCES products(id),
                quantity INT NOT NULL,
                total_price NUMERIC(12,2),
                purchase_time TIMESTAMP DEFAULT NOW(),
                region VARCHAR(100),
                payment_mode VARCHAR(50),
                status VARCHAR(50),
                PRIMARY KEY (id, region)
            ) PARTITION BY LIST (region)
        ';

        -- Step 3: Create partitions
        EXECUTE 'CREATE TABLE IF NOT EXISTS purchases_north PARTITION OF purchases FOR VALUES IN (''North'')';
        EXECUTE 'CREATE TABLE IF NOT EXISTS purchases_south PARTITION OF purchases FOR VALUES IN (''South'')';
        EXECUTE 'CREATE TABLE IF NOT EXISTS purchases_east PARTITION OF purchases FOR VALUES IN (''East'')';
        EXECUTE 'CREATE TABLE IF NOT EXISTS purchases_west PARTITION OF purchases FOR VALUES IN (''West'')';

        -- Step 4: Create Indexes for main table and partitions
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_purchase_time_desc ON purchases (purchase_time DESC)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_customer_id ON purchases (customer_id)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_product_id ON purchases (product_id)';

        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_north_purchase_time_desc ON purchases_north (purchase_time DESC)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_north_customer_id ON purchases_north (customer_id)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_north_product_id ON purchases_north (product_id)';

        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_south_purchase_time_desc ON purchases_south (purchase_time DESC)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_south_customer_id ON purchases_south (customer_id)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_south_product_id ON purchases_south (product_id)';

        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_east_purchase_time_desc ON purchases_east (purchase_time DESC)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_east_customer_id ON purchases_east (customer_id)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_east_product_id ON purchases_east (product_id)';

        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_west_purchase_time_desc ON purchases_west (purchase_time DESC)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_west_customer_id ON purchases_west (customer_id)';
        EXECUTE 'CREATE INDEX IF NOT EXISTS idx_purchases_west_product_id ON purchases_west (product_id)';

        -- Step 5: Directly migrate data into partitioned table
        EXECUTE '
            INSERT INTO purchases (id, customer_id, product_id, quantity, total_price, purchase_time, region, payment_mode, status)
            SELECT id, customer_id, product_id, quantity, total_price, purchase_time, region, payment_mode, status FROM purchases_backup
        ';

        -- Step 6: Drop backup table after migration (optional)
        -- EXECUTE 'DROP TABLE purchases_backup';

        -- Success response
        result := jsonb_build_object('success', true, 'message', 'Purchases migration completed successfully.');
    EXCEPTION
        WHEN OTHERS THEN
            -- Error response
            result := jsonb_build_object('success', false, 'message', SQLERRM, 'code', SQLSTATE);
    END;

    RETURN result;
END;
$$ LANGUAGE plpgsql;




-- extensions
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

