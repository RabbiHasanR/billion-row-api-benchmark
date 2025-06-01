-- 1. Search purchases with filters
CREATE OR REPLACE FUNCTION search_purchases(
    _customer_id INT DEFAULT NULL,
    _product_id INT DEFAULT NULL,
    _status TEXT DEFAULT NULL,
    _region TEXT DEFAULT NULL,
    _payment_mode TEXT DEFAULT NULL,
    _start_date TIMESTAMP DEFAULT NULL,
    _end_date TIMESTAMP DEFAULT NULL,
    _min_total_price NUMERIC DEFAULT NULL
)
RETURNS TABLE (
    id INT,
    customer_id INT,
    product_id INT,
    quantity INT,
    total_price NUMERIC,
    purchase_time TIMESTAMP,
    region TEXT,
    payment_mode TEXT,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM purchases
    WHERE
        (_customer_id IS NULL OR customer_id = _customer_id)
        AND (_product_id IS NULL OR product_id = _product_id)
        AND (_status IS NULL OR status = _status)
        AND (_region IS NULL OR region = _region)
        AND (_payment_mode IS NULL OR payment_mode = _payment_mode)
        AND (_start_date IS NULL OR purchase_time >= _start_date)
        AND (_end_date IS NULL OR purchase_time <= _end_date)
        AND (_min_total_price IS NULL OR total_price >= _min_total_price)
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;


-- 2. Sales trend by date interval (hour, day, week, month)
CREATE OR REPLACE FUNCTION sales_trend(
    _interval TEXT,
    _start_date TIMESTAMP,
    _end_date TIMESTAMP
)
RETURNS TABLE (
    period TIMESTAMP,
    total_sales NUMERIC
) AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'SELECT DATE_TRUNC(%L, purchase_time) AS period, SUM(total_price)
         FROM purchases
         WHERE purchase_time BETWEEN $1 AND $2
         GROUP BY period
         ORDER BY period', _interval
    ) USING _start_date, _end_date;
END;
$$ LANGUAGE plpgsql;


-- 3. Top customers by total purchase
CREATE OR REPLACE FUNCTION top_customers(
    _start_date TIMESTAMP,
    _end_date TIMESTAMP,
    _region TEXT DEFAULT NULL,
    _limit INT
)
RETURNS TABLE (
    id INT,
    name TEXT,
    total_spent NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.name, SUM(p.total_price) AS total_spent
    FROM purchases p
    JOIN customers c ON c.id = p.customer_id
    WHERE purchase_time BETWEEN _start_date AND _end_date
      AND (_region IS NULL OR p.region = _region)
    GROUP BY c.id, c.name
    ORDER BY total_spent DESC
    LIMIT _limit;
END;
$$ LANGUAGE plpgsql;


-- 4. Top selling products
CREATE OR REPLACE FUNCTION top_selling_products(
    _start_date TIMESTAMP,
    _end_date TIMESTAMP,
    _limit INT
)
RETURNS TABLE (
    id INT,
    name TEXT,
    purchase_count INT,
    revenue NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT pr.id, pr.name, COUNT(p.id), SUM(p.total_price)
    FROM purchases p
    JOIN products pr ON pr.id = p.product_id
    WHERE purchase_time BETWEEN _start_date AND _end_date
    GROUP BY pr.id, pr.name
    ORDER BY revenue DESC
    LIMIT _limit;
END;
$$ LANGUAGE plpgsql;
