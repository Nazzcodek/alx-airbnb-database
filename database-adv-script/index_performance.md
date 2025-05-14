# Database Indexing Performance Analysis

## Overview of Indexing Strategy

This document outlines the indexing strategy implemented for the Airbnb clone database, focusing on the high-usage tables: `user`, `property`, and `booking`.

## High-Usage Columns Identified

Based on analysis of query patterns in the application, the following columns were identified as high-usage:

### User Table

- `user_id`: Used in JOIN operations with booking and property tables
- `email`: Used in login/authentication queries
- `role`: Used for filtering users by role (host, guest, admin)

### Property Table

- `property_id`: Primary key, used in JOIN operations
- `host_id`: Used in JOIN operations with the user table
- `location`: Frequently used in WHERE clauses for location-based searches
- `price_per_night`: Used in filtering and sorting operations

### Booking Table

- `booking_id`: Primary key
- `property_id`: Used in JOIN operations with property table
- `user_id`: Used in JOIN operations with user table
- `start_date` and `end_date`: Used in date range queries
- `status`: Filtered for booking status (pending, confirmed, canceled)

## Indexes Created

### Existing Indexes (from schema)

- `user_user_id_email_index` on `user(user_id, email)`
- `property_property_id_index` on `property(property_id)`
- `booking_booking_id_property_id_index` on `booking(booking_id, property_id)`

### New Single-Column Indexes

- `idx_user_role` on `user(role)`
- `idx_property_host_id` on `property(host_id)`
- `idx_property_location` on `property(location)`
- `idx_property_price` on `property(price_per_night)`
- `idx_booking_user_id` on `booking(user_id)`
- `idx_booking_dates` on `booking(start_date, end_date)`
- `idx_booking_status` on `booking(status)`

### New Composite Indexes

- `idx_property_location_price` on `property(location, price_per_night)`
- `idx_booking_property_dates` on `booking(property_id, start_date, end_date)`

## Performance Improvement Analysis

### Query 1: Find all bookings for a specific user

**Before Indexing**: Full table scan of booking table followed by nested loop join with property table.  
**After Indexing**: Index seek on `idx_booking_user_id` followed by nested loop join with property table.  
**Expected Improvement**: 80-95% reduction in query execution time, especially for users with few bookings.

### Query 2: Find properties in a specific location with price filtering

**Before Indexing**: Full table scan of property table with filtering and sorting.  
**After Indexing**: Index seek on `idx_property_location_price` with direct access to ordered data.  
**Expected Improvement**: 70-90% reduction in query execution time, with greater improvements for larger datasets.

### Query 3: Find available properties for specific dates

**Before Indexing**: Multiple full table scans and complex filtering.  
**After Indexing**: Index seeks on booking dates and property prices.  
**Expected Improvement**: 60-80% reduction in query execution time for availability searches.

## Maintenance Considerations

1. **Regular Monitoring**: Monitor index usage and remove unused indexes to minimize storage overhead.
2. **Rebuilding**: Periodically rebuild indexes to reduce fragmentation.
3. **Write Performance**: Be aware that indexes slightly slow down INSERT, UPDATE, and DELETE operations.
4. **Storage Impact**: The added indexes will increase database size by approximately 10-15%.

## Conclusion

The implemented indexing strategy targets the most frequently accessed columns in the database. By adding these strategic indexes, we expect significant query performance improvements, particularly for property searches, booking operations, and user-specific queries. The trade-off in additional storage and slightly reduced write performance is justified by the substantial gains in read performance, which is the dominant operation type in this application.
