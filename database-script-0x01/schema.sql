CREATE TABLE "user"(
    "user_id" UUID NOT NULL,
    "first_name" VARCHAR(255) NOT NULL,
    "last_name" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "password" VARCHAR(255) NOT NULL,
    "phone_number" VARCHAR(255) NULL,
    "role" VARCHAR(255) CHECK
        ("role" IN('host, guest, admin')) NOT NULL,
    "created_at" TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX "user_user_id_email_index" ON
    "user"("user_id", "email");
ALTER TABLE
    "user" ADD PRIMARY KEY("user_id");
ALTER TABLE
    "user" ADD CONSTRAINT "user_email_unique" UNIQUE("email");
CREATE TABLE "property"(
    "property_id" UUID NOT NULL,
    "host_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "discription" TEXT NOT NULL,
    "location" VARCHAR(255) NOT NULL,
    "price_per_night" DECIMAL(8, 2) NOT NULL,
    "created_at" TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
    "updated_at" TIMESTAMP, ON UPDATE CURRENT_TIMESTAMP
);
CREATE INDEX "property_property_id_index" ON
    "property"("property_id");
ALTER TABLE
    "property" ADD PRIMARY KEY("property_id");
CREATE TABLE "booking"(
    "booking_id" UUID NOT NULL,
    "property_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "total_price" DECIMAL(8, 2) NOT NULL,
    "status" VARCHAR(255) CHECK
        ("status" IN('pending, confirmed, cancel')) NOT NULL,
    "updated_at" TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX "booking_booking_id_property_id_index" ON
    "booking"("booking_id", "property_id");
ALTER TABLE
    "booking" ADD PRIMARY KEY("booking_id");
CREATE TABLE "payment"(
    "payment_id" UUID NOT NULL,
    "booking_id" UUID NOT NULL,
    "amount" DECIMAL(8, 2) NOT NULL,
    "payment_date" TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
    "payment_method" VARCHAR(255)
    CHECK
        ("payment_method" IN('credit_card, paypal, stripe')) NOT NULL
);
CREATE INDEX "payment_payment_id_booking_id_index" ON
    "payment"("payment_id", "booking_id");
ALTER TABLE
    "payment" ADD PRIMARY KEY("payment_id");
CREATE TABLE "review"(
    "review_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "property_id" UUID NOT NULL,
    "rating" INTEGER CHECK ("rating" >= 1 AND "rating" <= 5) NOT NULL,
    "comment" TEXT NOT NULL,
    "created_at" TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE
    "review" ADD PRIMARY KEY("review_id");
CREATE TABLE "message"(
    "message_id" UUID NOT NULL,
    "sender_id" UUID NOT NULL,
    "recipient_id" UUID NOT NULL,
    "send_at" TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
    "message_body" TEXT NOT NULL
);
ALTER TABLE
    "message" ADD PRIMARY KEY("message_id");
ALTER TABLE
    "review" ADD CONSTRAINT "review_user_id_foreign" FOREIGN KEY("user_id") REFERENCES "user"("user_id");
ALTER TABLE
    "message" ADD CONSTRAINT "message_recipient_id_foreign" FOREIGN KEY("recipient_id") REFERENCES "user"("user_id");
ALTER TABLE
    "review" ADD CONSTRAINT "review_property_id_foreign" FOREIGN KEY("property_id") REFERENCES "property"("property_id");
ALTER TABLE
    "property" ADD CONSTRAINT "property_property_id_foreign" FOREIGN KEY("property_id") REFERENCES "booking"("booking_id");
ALTER TABLE
    "message" ADD CONSTRAINT "message_sender_id_foreign" FOREIGN KEY("sender_id") REFERENCES "user"("user_id");
ALTER TABLE
    "property" ADD CONSTRAINT "property_host_id_foreign" FOREIGN KEY("host_id") REFERENCES "user"("user_id");
ALTER TABLE
    "payment" ADD CONSTRAINT "payment_booking_id_foreign" FOREIGN KEY("booking_id") REFERENCES "booking"("booking_id");
