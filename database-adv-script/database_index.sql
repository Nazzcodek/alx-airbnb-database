-- Database Indexing for Performance Optimization
-- Date: 14 May 2025

-- =====================================================
-- PART 1: IDENTIFYING HIGH-USAGE COLUMNS
-- =====================================================
/*
Based on query analysis, high-usage columns include:
1. user table: user_id (for JOIN), email (for searches), role (for filtering)
2. property table: host_id (for JOIN), location (for searches), price_per_night (for sorting/filtering) 
3. booking table: user_id (for JOIN), property_id (for JOIN), start_date/end_date (for date range queries)
*/

-- =====================================================
-- PART 2: PERFORMANCE MEASUREMENT BEFORE INDEXING
-- =====================================================

-- Query 1: Find all bookings for a specific user - BEFORE INDEXING
EXPLAIN ANALYZE
SELECT b.booking_id, p.name, b.start_date, b.end_date, b.total_price
FROM booking b
JOIN property p ON b.property_id = p.property_id
WHERE b.user_id = 'some-user-id-value';

-- Query 2: Find properties in a specific location with price filtering - BEFORE INDEXING
EXPLAIN ANALYZE
SELECT property_id, name, price_per_night
FROM property
WHERE location = 'New York'
AND price_per_night < 200.00
ORDER BY price_per_night ASC;

-- Query 3: Find available properties for specific dates - BEFORE INDEXING
EXPLAIN ANALYZE
SELECT p.property_id, p.name, p.location, p.price_per_night
FROM property p
WHERE p.property_id NOT IN (
    SELECT property_id
    FROM booking
    WHERE status = 'confirmed'
    AND (
        (start_date <= '2025-06-15' AND end_date >= '2025-06-10')
        OR
        (start_date <= '2025-06-20' AND end_date >= '2025-06-15')
    )
)
ORDER BY p.price_per_night ASC;

-- =====================================================
-- PART 3: CREATING INDEXES FOR HIGH-USAGE COLUMNS
-- =====================================================

-- Existing indexes from schema (not creating these again):
-- user_user_id_email_index on user(user_id, email)
-- property_property_id_index on property(property_id)
-- booking_booking_id_property_id_index on booking(booking_id, property_id)

-- New indexes for User table
CREATE INDEX idx_user_role ON "user" (role);

-- New indexes for Property table
CREATE INDEX idx_property_host_id ON property (host_id);
CREATE INDEX idx_property_location ON property (location);
CREATE INDEX idx_property_price ON property (price_per_night);

-- New indexes for Booking table
CREATE INDEX idx_booking_user_id ON booking (user_id);
CREATE INDEX idx_booking_dates ON booking (start_date, end_date);
CREATE INDEX idx_booking_status ON booking (status);

-- Composite index for common filtering patterns
CREATE INDEX idx_property_location_price ON property (location, price_per_night);
CREATE INDEX idx_booking_property_dates ON booking (property_id, start_date, end_date);

-- =====================================================
-- PART 4: PERFORMANCE MEASUREMENT AFTER INDEXING
-- =====================================================

-- Query 1: Find all bookings for a specific user - AFTER INDEXING
EXPLAIN ANALYZE
SELECT b.booking_id, p.name, b.start_date, b.end_date, b.total_price
FROM booking b
JOIN property p ON b.property_id = p.property_id
WHERE b.user_id = 'some-user-id-value';

-- Query 2: Find properties in a specific location with price filtering - AFTER INDEXING
EXPLAIN ANALYZE
SELECT property_id, name, price_per_night
FROM property
WHERE location = 'New York'
AND price_per_night < 200.00
ORDER BY price_per_night ASC;

-- Query 3: Find available properties for specific dates - AFTER INDEXING
EXPLAIN ANALYZE
SELECT p.property_id, p.name, p.location, p.price_per_night
FROM property p
WHERE p.property_id NOT IN (
    SELECT property_id
    FROM booking
    WHERE status = 'confirmed'
    AND (
        (start_date <= '2025-06-15' AND end_date >= '2025-06-10')
        OR
        (start_date <= '2025-06-20' AND end_date >= '2025-06-15')
    )
)
ORDER BY p.price_per_night ASC;

-- =====================================================
-- PART 5: INDEX MAINTENANCE CONSIDERATIONS
-- =====================================================
/*
Index Performance Impact:
1. Query Performance: Indexes significantly improve SELECT query performance when filtering, joining, or sorting data
2. Write Operations: Indexes slightly slow down INSERT, UPDATE, and DELETE operations as they need to be maintained
3. Storage: Indexes require additional storage space

Best Practices:
1. Only create indexes on columns frequently used in WHERE clauses, JOIN conditions, or ORDER BY statements
2. Consider composite indexes for queries that filter on multiple columns
3. Monitor index usage and remove unused indexes
4. Rebuild indexes periodically if they become fragmented
*/