-- schema.sql
-- PostgreSQL DDL for ALX Airbnb Database

-- Drop if exists (safe for reruns)
DROP TABLE IF EXISTS property_amenities CASCADE;
DROP TABLE IF EXISTS property_images CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS amenities CASCADE;
DROP TABLE IF EXISTS properties CASCADE;
DROP TABLE IF EXISTS cities CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Users
CREATE TABLE users (
  user_id SERIAL PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  phone VARCHAR(32),
  role VARCHAR(20) NOT NULL DEFAULT 'guest', -- guest | host | admin
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Cities
CREATE TABLE cities (
  city_id SERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  country VARCHAR(120) NOT NULL,
  region VARCHAR(120),
  UNIQUE (name, country)
);

-- Properties
CREATE TABLE properties (
  property_id SERIAL PRIMARY KEY,
  owner_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  city_id INTEGER NOT NULL REFERENCES cities(city_id) ON DELETE SET NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  address VARCHAR(300),
  price_per_night NUMERIC(10,2) NOT NULL CHECK (price_per_night >= 0),
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  max_guests SMALLINT NOT NULL DEFAULT 2 CHECK (max_guests > 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Amenities
CREATE TABLE amenities (
  amenity_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

-- Property <-> Amenity many-to-many
CREATE TABLE property_amenities (
  property_id INTEGER NOT NULL REFERENCES properties(property_id) ON DELETE CASCADE,
  amenity_id INTEGER NOT NULL REFERENCES amenities(amenity_id) ON DELETE CASCADE,
  PRIMARY KEY (property_id, amenity_id)
);

-- Property images
CREATE TABLE property_images (
  image_id SERIAL PRIMARY KEY,
  property_id INTEGER NOT NULL REFERENCES properties(property_id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  caption VARCHAR(200),
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bookings
CREATE TABLE bookings (
  booking_id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE, -- guest
  property_id INTEGER NOT NULL REFERENCES properties(property_id) ON DELETE CASCADE,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  nights INTEGER NOT NULL CHECK (nights > 0),
  total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  status VARCHAR(30) NOT NULL DEFAULT 'pending', -- pending | confirmed | cancelled | completed
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT chk_dates CHECK (end_date > start_date)
);

-- Payments
CREATE TABLE payments (
  payment_id SERIAL PRIMARY KEY,
  booking_id INTEGER NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
  amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  method VARCHAR(50) NOT NULL, -- card | paypal | bank_transfer | cash
  status VARCHAR(30) NOT NULL DEFAULT 'paid', -- paid | pending | failed | refunded
  paid_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB
);

-- Reviews
CREATE TABLE reviews (
  review_id SERIAL PRIMARY KEY,
  booking_id INTEGER NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
  reviewer_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE (booking_id, reviewer_id)
);

-- Indexes for performance
CREATE INDEX idx_properties_city ON properties (city_id);
CREATE INDEX idx_properties_owner ON properties (owner_id);
CREATE INDEX idx_bookings_property ON bookings (property_id);
CREATE INDEX idx_bookings_user ON bookings (user_id);
CREATE INDEX idx_payments_booking ON payments (booking_id);

-- A helpful view: property availability summary (optional)
-- (This is an example; actual availability calendar logic is beyond schema-only)
CREATE VIEW property_summary AS
SELECT p.property_id, p.title, p.price_per_night, p.currency, c.name AS city, u.full_name AS owner
FROM properties p
LEFT JOIN cities c ON p.city_id = c.city_id
LEFT JOIN users u ON p.owner_id = u.user_id;
