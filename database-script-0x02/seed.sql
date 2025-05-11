--USERS
-- Host
INSERT INTO "user" ("user_id", "first_name", "last_name", "email", "password", "role", "created_at")
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'John',
    'Doe',
    'john.doe@example.com',
    'hashed_password_123',
    'host',
    '2024-03-01 09:00:00'
);

-- Guest
INSERT INTO "user" ("user_id", "first_name", "last_name", "email", "password", "role", "created_at")
VALUES (
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12',
    'Alice',
    'Smith',
    'alice.smith@example.com',
    'hashed_password_456',
    'guest',
    '2024-03-05 14:30:00'
);

-- Admin
INSERT INTO "user" ("user_id", "first_name", "last_name", "email", "password", "role", "phone_number", "created_at")
VALUES (
    'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13',
    'Bob',
    'Admin',
    'bob.admin@example.com',
    'hashed_password_789',
    'admin',
    '+1234567890',
    '2024-02-15 08:15:00'
);

-- PROPERTIES
-- Beach House (owned by John)
INSERT INTO "property" ("property_id", "host_id", "name", "discription", "location", "price_per_night", "created_at")
VALUES (
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a14',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Ocean View Villa',
    'Luxury beachfront property with 3 bedrooms',
    'Malibu, CA',
    450.00,
    '2024-01-10 10:00:00'
);

-- City Apartment (owned by John)
INSERT INTO "property" ("property_id", "host_id", "name", "discription", "location", "price_per_night", "created_at")
VALUES (
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Downtown Loft',
    'Modern apartment near central business district',
    'New York, NY',
    300.00,
    '2024-02-01 12:00:00'
);

-- BOOKINGS
-- Alice books the Beach House (confirmed)
INSERT INTO "booking" ("booking_id", "property_id", "user_id", "start_date", "end_date", "total_price", "status", "updated_at")
VALUES (
    'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a16',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a14',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12',
    '2024-06-01',
    '2024-06-07',
    2700.00,  -- 6 nights × $450
    'confirmed',
    '2024-03-10 16:45:00'
);

-- Alice books the City Apartment (pending)
INSERT INTO "booking" ("booking_id", "property_id", "user_id", "start_date", "end_date", "total_price", "status", "updated_at")
VALUES (
    'g6eebc99-9c0b-4ef8-bb6d-6bb9bd380a17',
    'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12',
    '2024-07-15',
    '2024-07-20',
    1500.00,  -- 5 nights × $300
    'pending',
    '2024-03-12 11:20:00'
);

-- PAYMENTS
-- Payment for Beach House booking
INSERT INTO "payment" ("payment_id", "booking_id", "amount", "payment_method", "payment_date")
VALUES (
    'h7eebc99-9c0b-4ef8-bb6d-6bb9bd380a18',
    'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a16',
    2700.00,
    'credit_card',
    '2024-03-10 17:00:00'
); 

-- Partial payment for City Apartment booking
INSERT INTO "payment" ("payment_id", "booking_id", "amount", "payment_method", "payment_date")
VALUES (
    'i8eebc99-9c0b-4ef8-bb6d-6bb9bd380a19',
    'g6eebc99-9c0b-4ef8-bb6d-6bb9bd380a17',
    500.00,
    'paypal',
    '2024-03-12 11:30:00'
);

-- REVIEWS
-- Alice reviews the Beach House
INSERT INTO "review" ("review_id", "user_id", "property_id", "rating", "comment", "created_at")
VALUES (
    'j9eebc99-9c0b-4ef8-bb6d-6bb9bd380a20',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a14',
    5,
    'Amazing views and excellent service!',
    '2024-06-08 10:00:00'
);

-- MESSAGES
-- Message from Alice to John
INSERT INTO "message" ("message_id", "sender_id", "recipient_id", "message_body", "send_at")
VALUES (
    'k0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Hi John, is the beach house pet-friendly?',
    '2024-05-01 15:30:00'
);
