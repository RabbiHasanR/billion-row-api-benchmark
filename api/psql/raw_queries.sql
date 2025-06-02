CREATE OR REPLACE FUNCTION latest_purchases(
    _limit INT DEFAULT 100,
    _region TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    result_json JSON;
BEGIN
    RETURN (
        SELECT json_build_object(
            'success', true,
            'data', json_agg(row_to_json(t)),
            'message', 'Fetched latest purchases'
        )
        FROM (
            SELECT
                p.id,
                p.customer_id,
                c.name AS customer_name,
                c.email AS customer_email,
                p.product_id,
                pr.name AS product_name,
                pr.category AS product_category,
                p.total_price,
                p.quantity,
                p.purchase_time,
                p.region,
                p.status
            FROM purchases p
            JOIN customers c ON c.id = p.customer_id
            JOIN products pr ON pr.id = p.product_id
            WHERE (_region IS NULL OR p.region = _region)
            ORDER BY p.purchase_time DESC
            LIMIT _limit
        ) t
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'data', NULL,
            'message', SQLERRM,
            'code', SQLSTATE
        );
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION analyze_latest_purchases(
    _limit INT DEFAULT 100,
    _region TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    sql TEXT;
    plan_result JSON;
BEGIN
    sql := '
        EXPLAIN (ANALYZE, FORMAT JSON)
        SELECT
            p.id,
            p.customer_id,
            c.name,
            p.product_id,
            pr.name,
            p.total_price,
            p.purchase_time,
            p.region,
            p.status
        FROM purchases p
        JOIN customers c ON c.id = p.customer_id
        JOIN products pr ON pr.id = p.product_id
        WHERE ' || 
        CASE 
            WHEN _region IS NULL THEN 'TRUE'
            ELSE 'p.region = $1'
        END || '
        ORDER BY p.purchase_time DESC
        LIMIT ' || _limit;

    IF _region IS NULL THEN
        EXECUTE sql INTO plan_result;
    ELSE
        EXECUTE sql USING _region INTO plan_result;
    END IF;

    RETURN json_build_object(
        'success', true,
        'analyze', plan_result,
        'message', 'Analyze completed'
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'analyze', NULL,
            'message', SQLERRM,
            'code', SQLSTATE
        );
END;
$$ LANGUAGE plpgsql;

