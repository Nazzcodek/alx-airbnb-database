-- Initial Query: Retrieve all bookings with user, property, and payment details

-- Version 1: Original query with all joins
EXPLAIN ANALYZE
SELECT 
    b.booking_id, 
    b.start_date, 
    b.end_date, 
    b.total_price,
    b.status,
    u.user_id, 
    u.first_name, 
    u.last_name, 
    u.email,
    p.property_id, 
    p.name AS property_name, 
    p.location, 
    p.price_per_night,
    pay.payment_id, 
    pay.amount, 
    pay.payment_date, 
    pay.payment_method
FROM 
    booking b
JOIN 
    "user" u ON b.user_id = u.user_id
JOIN 
    property p ON b.property_id = p.property_id
LEFT JOIN 
    payment pay ON b.booking_id = pay.booking_id
ORDER BY 
    b.start_date DESC;

-- Analysis of query performance problems:
/*
1. The main query joins multiple large tables (booking, user, property, payment)
2. It retrieves all columns from these tables, which can be excessive
3. The sorting operation on start_date might be expensive without proper indexing
4. No filters are applied, so it retrieves the entire dataset
*/

-- Version 2: Optimized query with selective columns and proper indexing
EXPLAIN ANALYZE
SELECT 
    b.booking_id, 
    b.start_date, 
    b.end_date, 
    b.status,
    u.user_id, 
    u.first_name, 
    u.last_name, 
    p.property_id, 
    p.name AS property_name, 
    p.location,
    COALESCE(pay.payment_id, 'Not Paid') AS payment_status
FROM 
    booking b
JOIN 
    "user" u ON b.user_id = u.user_id
JOIN 
    property p ON b.property_id = p.property_id
LEFT JOIN 
    (SELECT booking_id, payment_id FROM payment) pay ON b.booking_id = pay.booking_id
WHERE 
    b.start_date >= '2025-01-01'
ORDER BY 
    b.start_date DESC
LIMIT 100;

-- Version 3: Query with more efficient JOIN order
EXPLAIN ANALYZE
SELECT 
    b.booking_id, 
    b.start_date, 
    b.end_date, 
    b.status,
    u.first_name || ' ' || u.last_name AS guest_name,
    p.name AS property_name, 
    p.location,
    CASE WHEN pay.payment_id IS NOT NULL THEN 'Paid' ELSE 'Not Paid' END AS payment_status
FROM 
    booking b
JOIN 
    property p ON b.property_id = p.property_id
JOIN 
    "user" u ON b.user_id = u.user_id
LEFT JOIN 
    (SELECT DISTINCT booking_id, payment_id FROM payment) pay ON b.booking_id = pay.booking_id
WHERE 
    b.start_date BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY 
    b.start_date DESC
LIMIT 50;

-- Performance comparison between the three queries:
/*
Query 1 (Original):
- Retrieves all columns from all tables
- No filtering conditions
- Full table scans likely on all tables
- Heavy memory usage for result set

Query 2 (First optimization):
- Selects only necessary columns
- Uses subquery to limit payment fields
- Adds date filter to reduce result set
- Limits results to 100 rows
- Uses existing indexes on join conditions

Query 3 (Further optimization):
- Reorders joins to start with booking table (main filtering point)
- Concatenates first and last name to reduce data transfer
- Uses CASE expression for simplified payment status
- Uses BETWEEN for more efficient date range filtering
- Further limits to 50 rows for quicker response
- Uses DISTINCT in the payment subquery to avoid duplicates
*/

-- Recommendations for further optimization:
/*
1. Create additional indexes if not already present:
   - CREATE INDEX idx_booking_start_date ON booking(start_date);
   - CREATE INDEX idx_booking_status ON booking(status);

2. Consider materialized views for frequently accessed booking reports

3. For production environments with large datasets:
   - Implement pagination instead of LIMIT
   - Consider partitioning the booking table by date ranges
   - Use connection pooling to reduce connection overhead
   - Implement caching for frequently accessed data
*/