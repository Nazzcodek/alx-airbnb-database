-- This SQL script demonstrates how to use INNER JOIN to combine data from two tables: users and bookings.
-- It retrieves all columns from both tables where the user ID matches in both tables.
-- The INNER JOIN clause is used to combine rows from both tables based on the specified condition.
-- The result will include all columns from both tables for users who have made bookings.
SELECT * FROM users u
INNER JOIN bookings b
ON u.id = b.user_id


-- This SQL script demonstrates how to use LEFT JOIN to combine data from two tables: Properties and Reviews.
-- It retrieves all columns from both tables, including properties that may not have any reviews.
-- The LEFT JOIN clause is used to include all rows from the left table (properties) and the matching rows from the right table (reviews).
-- If there are no matching reviews for a property, the result will still include the property with NULL values for the review columns.
SELECT * FROM properties p
LEFT JOIN reviews r
ON p.id = r.property_id
ORDER BY p.id


-- This SQL script demonstrates how to use FULL OUTER JOIN to combine data from two tables: users and bookings.
-- It retrieves all columns from both tables, including users who may not have made any bookings.
-- The FULL OUTER JOIN clause is used to include all rows from both tables, regardless of whether there is a match.
-- If there are no matching bookings for a user, the result will still include the user with NULL values for the booking columns.
SELECT * FROM users u
FULL OUTER JOIN bookings b
ON u.id = b.user_id