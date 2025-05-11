CREATE TABLE "user" (
    "user_id" UUID NOT NULL,
    "first_name" VARCHAR(255) NOT NULL,
    "last_name" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "password" VARCHAR(255) NOT NULL,
    "phone_number" VARCHAR(255),
    "role" VARCHAR(255) NOT NULL CHECK ("role" IN ('host', 'guest', 'admin')),
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("user_id"),
    UNIQUE ("email")
);

CREATE INDEX "user_user_id_email_index" ON "user" ("user_id", "email");


CREATE TABLE "property" (
    "property_id" UUID NOT NULL,
    "host_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "location" VARCHAR(255) NOT NULL,
    "price_per_night" DECIMAL(8, 2) NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("property_id"),
    CONSTRAINT "property_host_id_foreign" FOREIGN KEY ("host_id") REFERENCES "user" ("user_id")
);

CREATE INDEX "property_property_id_index" ON "property" ("property_id");


CREATE TABLE "booking" (
    "booking_id" UUID NOT NULL,
    "property_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "total_price" DECIMAL(8, 2) NOT NULL,
    "status" VARCHAR(255) NOT NULL CHECK ("status" IN ('pending', 'confirmed', 'cancel')),
    "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("booking_id"),
    CONSTRAINT "booking_property_id_foreign" FOREIGN KEY ("property_id") REFERENCES "property" ("property_id"),
    CONSTRAINT "booking_user_id_foreign" FOREIGN KEY ("user_id") REFERENCES "user" ("user_id")
);

CREATE INDEX "booking_booking_id_property_id_index" ON "booking" ("booking_id", "property_id");


CREATE TABLE "payment" (
    "payment_id" UUID NOT NULL,
    "booking_id" UUID NOT NULL,
    "amount" DECIMAL(8, 2) NOT NULL,
    "payment_date" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "payment_method" VARCHAR(255) NOT NULL CHECK ("payment_method" IN ('credit_card', 'paypal', 'stripe')),
    PRIMARY KEY ("payment_id"),
    CONSTRAINT "payment_booking_id_foreign" FOREIGN KEY ("booking_id") REFERENCES "booking" ("booking_id")
);

CREATE INDEX "payment_payment_id_booking_id_index" ON "payment" ("payment_id", "booking_id");


CREATE TABLE "review" (
    "review_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "property_id" UUID NOT NULL,
    "rating" INTEGER NOT NULL CHECK ("rating" >= 1 AND "rating" <= 5),
    "comment" TEXT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("review_id"),
    CONSTRAINT "review_user_id_foreign" FOREIGN KEY ("user_id") REFERENCES "user" ("user_id"),
    CONSTRAINT "review_property_id_foreign" FOREIGN KEY ("property_id") REFERENCES "property" ("property_id")
);


CREATE TABLE "message" (
    "message_id" UUID NOT NULL,
    "sender_id" UUID NOT NULL,
    "recipient_id" UUID NOT NULL,
    "send_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "message_body" TEXT NOT NULL,
    PRIMARY KEY ("message_id"),
    CONSTRAINT "message_sender_id_foreign" FOREIGN KEY ("sender_id") REFERENCES "user" ("user_id"),
    CONSTRAINT "message_recipient_id_foreign" FOREIGN KEY ("recipient_id") REFERENCES "user" ("user_id")
);
