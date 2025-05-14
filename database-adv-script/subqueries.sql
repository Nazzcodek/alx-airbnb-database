-- Subquery to find all properties where the average rating is greater than 4.0
--
-- This subquery calculates the average rating for each property and filters those with an average rating greater than 4.0.
-- It then selects the property details along with the average rating.
SELECT p.property_id, p.name, p.location, p.price_per_night,
       (SELECT AVG(rating) 
        FROM review r 
        WHERE r.property_id = p.property_id) 
        AS average_rating
FROM property p
WHERE (
    SELECT AVG(rating)
    FROM review r 
    WHERE r.property_id = p.property_id
    ) > 4.0
ORDER BY average_rating DESC;

-- Correlated subquery to find users who have made more than 3 bookings
--
-- This subquery counts the number of bookings for each user and filters those with more than 3 bookings.
-- It then selects the user details along with the booking count.
-- Note: The subquery is correlated with the outer query by referencing the user_id from the outer query.
SELECT u.user_id, u.first_name, u.last_name, u.email,
       (SELECT COUNT(*) 
        FROM booking b 
        WHERE b.user_id = u.user_id) AS booking_count
FROM users u
WHERE (
    SELECT COUNT(*) 
    FROM booking b 
    WHERE b.user_id = u.user_id
    ) > 3
ORDER BY booking_count DESC;