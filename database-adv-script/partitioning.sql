-- Partitioning Implementation for Booking Table
-- Date: 14 May 2025

-- Step 1: Create a partitioned version of the booking table
CREATE TABLE booking_partitioned (
    booking_id UUID NOT NULL,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(8, 2) NOT NULL,
    status VARCHAR(255) NOT NULL CHECK (status IN ('pending', 'confirmed', 'cancel')),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id, start_date),
    CONSTRAINT booking_property_id_foreign FOREIGN KEY (property_id) REFERENCES property (property_id),
    CONSTRAINT booking_user_id_foreign FOREIGN KEY (user_id) REFERENCES "user" (user_id)
) PARTITION BY RANGE (start_date);

-- Step 2: Create partitions by quarter for the current year (2025)
CREATE TABLE booking_q1_2025 PARTITION OF booking_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');

CREATE TABLE booking_q2_2025 PARTITION OF booking_partitioned
    FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');

CREATE TABLE booking_q3_2025 PARTITION OF booking_partitioned
    FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');

CREATE TABLE booking_q4_2025 PARTITION OF booking_partitioned
    FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

-- Create additional partitions for historical data
CREATE TABLE booking_historical PARTITION OF booking_partitioned
    FOR VALUES FROM ('2020-01-01') TO ('2025-01-01');

-- Create partition for future bookings
CREATE TABLE booking_future PARTITION OF booking_partitioned
    FOR VALUES FROM ('2026-01-01') TO ('2030-01-01');

-- Step 3: Create appropriate indexes on the partitioned table
CREATE INDEX idx_booking_part_property_id ON booking_partitioned (property_id);
CREATE INDEX idx_booking_part_user_id ON booking_partitioned (user_id);
CREATE INDEX idx_booking_part_dates ON booking_partitioned (start_date, end_date);
CREATE INDEX idx_booking_part_status ON booking_partitioned (status);

-- Step 4: Migrate data from the original booking table to the partitioned table
-- Note: In a production environment, this would typically be done in smaller batches
-- to avoid locking the table for extended periods
INSERT INTO booking_partitioned
SELECT * FROM booking;

-- Step 5: Performance testing queries

-- Query 1: Test performance on original booking table - filter by date range
EXPLAIN ANALYZE
SELECT booking_id, property_id, user_id, start_date, end_date, status
FROM booking
WHERE start_date BETWEEN '2025-04-01' AND '2025-06-30'
ORDER BY start_date;

-- Query 2: Test performance on partitioned booking table - same filter
EXPLAIN ANALYZE
SELECT booking_id, property_id, user_id, start_date, end_date, status
FROM booking_partitioned
WHERE start_date BETWEEN '2025-04-01' AND '2025-06-30'
ORDER BY start_date;

-- Query 3: Test performance with joining to user and property tables (original)
EXPLAIN ANALYZE
SELECT b.booking_id, b.start_date, b.end_date, u.first_name, u.last_name, p.name AS property_name
FROM booking b
JOIN "user" u ON b.user_id = u.user_id
JOIN property p ON b.property_id = p.property_id
WHERE b.start_date BETWEEN '2025-04-01' AND '2025-06-30'
ORDER BY b.start_date;

-- Query 4: Test performance with joining to user and property tables (partitioned)
EXPLAIN ANALYZE
SELECT b.booking_id, b.start_date, b.end_date, u.first_name, u.last_name, p.name AS property_name
FROM booking_partitioned b
JOIN "user" u ON b.user_id = u.user_id
JOIN property p ON b.property_id = p.property_id
WHERE b.start_date BETWEEN '2025-04-01' AND '2025-06-30'
ORDER BY b.start_date;

-- Query 5: Test aggregate performance on original table
EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('month', start_date) AS booking_month,
    COUNT(*) AS total_bookings,
    SUM(total_price) AS revenue
FROM booking
WHERE start_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY DATE_TRUNC('month', start_date)
ORDER BY booking_month;

-- Query 6: Test aggregate performance on partitioned table
EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('month', start_date) AS booking_month,
    COUNT(*) AS total_bookings,
    SUM(total_price) AS revenue
FROM booking_partitioned
WHERE start_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY DATE_TRUNC('month', start_date)
ORDER BY booking_month;

-- Step 6: Maintenance and management for partition tables

-- Add a new partition for Q1 2026 when needed
-- CREATE TABLE booking_q1_2026 PARTITION OF booking_partitioned
--    FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');

-- Function to automatically create new quarterly partitions
CREATE OR REPLACE FUNCTION create_booking_partition_for_quarter(year INT, quarter INT)
RETURNS VOID AS $$
DECLARE
    start_date DATE;
    end_date DATE;
    partition_name TEXT;
BEGIN
    -- Calculate start and end dates for the quarter
    start_date := make_date(year, ((quarter - 1) * 3) + 1, 1);
    
    IF quarter < 4 THEN
        end_date := make_date(year, ((quarter) * 3) + 1, 1);
    ELSE
        end_date := make_date(year + 1, 1, 1);
    END IF;
    
    -- Create partition name
    partition_name := 'booking_q' || quarter || '_' || year;
    
    -- Create the partition
    EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF booking_partitioned
                    FOR VALUES FROM (%L) TO (%L)',
                    partition_name, start_date, end_date);
                    
    RAISE NOTICE 'Created partition % for range % to %', partition_name, start_date, end_date;
END;
$$ LANGUAGE plpgsql;

-- Example usage:
-- SELECT create_booking_partition_for_quarter(2026, 1);