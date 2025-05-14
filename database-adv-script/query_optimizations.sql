-- Query Optimization and Performance Monitoring
-- Date: 14 May 2025

-- Enable query profiling in PostgreSQL (run once per session)
LOAD 'auto_explain';
SET auto_explain.log_min_duration = '100ms';
SET auto_explain.log_analyze = true;
SET auto_explain.log_buffers = true;
SET auto_explain.log_timing = true;
SET auto_explain.log_nested_statements = true;

-- 1. Add additional performance-focused indexes
-- Note: These complement existing indexes in schema.sql

-- Index for text search on property location (requires pg_trgm extension)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_property_location_trgm ON property USING gin (location gin_trgm_ops);

-- Composite indexes for booking table
CREATE INDEX idx_booking_dates_status ON booking (start_date, end_date, status);
CREATE INDEX idx_booking_status_date ON booking (status, start_date);

-- 2. Query 1: Available properties in location for date range
-- Original query
EXPLAIN ANALYZE
SELECT p.property_id, p.name, p.location, p.price_per_night
FROM property p
WHERE p.location LIKE '%New York%'
AND p.property_id NOT IN (
    SELECT property_id
    FROM booking
    WHERE status = 'confirmed'
    AND (
        (start_date <= '2025-05-20' AND end_date >= '2025-05-15')
        OR
        (start_date <= '2025-05-25' AND end_date >= '2025-05-20')
    )
)
ORDER BY p.price_per_night ASC;

-- Optimized query (using NOT EXISTS and more efficient join pattern)
EXPLAIN ANALYZE
SELECT p.property_id, p.name, p.location, p.price_per_night
FROM property p
WHERE p.location LIKE '%New York%'
AND NOT EXISTS (
    SELECT 1
    FROM booking b
    WHERE b.property_id = p.property_id
    AND b.status = 'confirmed'
    AND (
        (b.start_date <= '2025-05-20' AND b.end_date >= '2025-05-15')
        OR
        (b.start_date <= '2025-05-25' AND b.end_date >= '2025-05-20')
    )
)
ORDER BY p.price_per_night ASC;

-- 3. Query 2: User booking history with property details
-- Original query
EXPLAIN ANALYZE
SELECT b.booking_id, b.start_date, b.end_date, 
       p.name AS property_name, p.location, b.total_price
FROM booking b
JOIN property p ON b.property_id = p.property_id
WHERE b.user_id = 'some-user-id'
ORDER BY b.start_date DESC;

-- Optimized query with LIMIT
EXPLAIN ANALYZE
SELECT b.booking_id, b.start_date, b.end_date, 
       p.name AS property_name, p.location, b.total_price
FROM booking b
JOIN property p ON b.property_id = p.property_id
WHERE b.user_id = 'some-user-id'
ORDER BY b.start_date DESC
LIMIT 50;

-- 4. Query 3: Monthly revenue report
-- Original query
EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('month', b.start_date) AS month,
    COUNT(b.booking_id) AS booking_count,
    SUM(b.total_price) AS total_revenue
FROM booking b
WHERE b.status = 'confirmed'
AND b.start_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY DATE_TRUNC('month', b.start_date)
ORDER BY month;

-- Optimized query using CTE
EXPLAIN ANALYZE
WITH monthly_bookings AS (
    SELECT 
        DATE_TRUNC('month', start_date) AS month,
        COUNT(booking_id) AS booking_count,
        SUM(total_price) AS total_revenue
    FROM booking
    WHERE status = 'confirmed'
    AND start_date BETWEEN '2025-01-01' AND '2025-12-31'
    GROUP BY DATE_TRUNC('month', start_date)
)
SELECT month, booking_count, total_revenue
FROM monthly_bookings
ORDER BY month;

-- 5. Performance statistics collection queries

-- Check which queries are using the most resources (PostgreSQL)
SELECT query, calls, total_exec_time, rows, 
       100.0 * total_exec_time / sum(total_exec_time) OVER() AS percent_total
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

-- Check index usage statistics
SELECT 
    schemaname, 
    relname, 
    indexrelname, 
    idx_scan, 
    idx_tup_read, 
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Check for unused indexes
SELECT 
    s.schemaname,
    s.relname AS tablename,
    s.indexrelname AS indexname,
    pg_size_pretty(pg_relation_size(quote_ident(s.schemaname)::text || '.' || quote_ident(s.indexrelname)::text)) AS index_size
FROM pg_stat_user_indexes s
JOIN pg_index i ON s.indexrelid = i.indexrelid
WHERE s.idx_scan = 0      -- has never been scanned
AND NOT i.indisprimary    -- is not a PRIMARY KEY
AND NOT i.indisunique     -- is not a UNIQUE index
ORDER BY pg_relation_size(quote_ident(s.schemaname)::text || '.' || quote_ident(s.indexrelname)::text) DESC;

-- 6. To collect execution statistics over time
-- Create a simple table for storing query metrics
CREATE TABLE IF NOT EXISTS query_performance_log (
    id SERIAL PRIMARY KEY,
    query_id VARCHAR(100),
    query_text TEXT,
    execution_time_ms NUMERIC,
    rows_returned INTEGER,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Function to log query performance
CREATE OR REPLACE FUNCTION log_query_performance(p_query_id VARCHAR, p_query_text TEXT, p_execution_time_ms NUMERIC, p_rows_returned INTEGER)
RETURNS VOID AS $$
BEGIN
    INSERT INTO query_performance_log (query_id, query_text, execution_time_ms, rows_returned)
    VALUES (p_query_id, p_query_text, p_execution_time_ms, p_rows_returned);
END;
$$ LANGUAGE plpgsql;

-- Example usage:
-- SELECT log_query_performance('avail-properties-nyc', 'SELECT p.property_id...', 120.5, 42);

-- Query to analyze performance trends over time
SELECT 
    query_id, 
    MIN(execution_time_ms) AS min_time,
    AVG(execution_time_ms) AS avg_time,
    MAX(execution_time_ms) AS max_time,
    AVG(rows_returned) AS avg_rows,
    COUNT(*) AS execution_count
FROM query_performance_log
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY query_id
ORDER BY avg_time DESC;