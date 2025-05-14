-- Count of bookings made by each user with their details
SELECT u.user_id, u.first_name, u.last_name, u.email, COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email
ORDER BY total_bookings DESC;

-- Ranking properties based on their total bookings using ROW_NUMBER
SELECT 
    p.property_id, 
    p.name, 
    p.location, 
    p.price_per_night,
    COUNT(b.booking_id) AS total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.price_per_night
ORDER BY total_bookings DESC;

-- Alternative ranking using RANK() function which allows for ties
SELECT 
    p.property_id, 
    p.name, 
    p.location, 
    p.price_per_night,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.price_per_night
ORDER BY booking_rank ASC;
