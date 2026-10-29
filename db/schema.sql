-- =============================================================================
-- Itinerboon Travel Platform — NeonDB Serverless PostgreSQL Schema & Seed Data
-- Run in Neon SQL Editor (https://console.neon.tech) or via `npm run db:schema`
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Properties Table (Stays: Hotels, Resorts, Villas, Ryokans, Chalets)
CREATE TABLE IF NOT EXISTS properties (
  id VARCHAR(64) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  category VARCHAR(64) NOT NULL, -- 'Resort', 'Boutique Hotel', 'Villa', 'Chalet', 'Ryokan', 'Penthouse'
  city VARCHAR(120) NOT NULL,
  country VARCHAR(120) NOT NULL,
  neighborhood VARCHAR(160) NOT NULL,
  distance_from_center VARCHAR(80) NOT NULL,
  coordinates JSONB NOT NULL DEFAULT '{"lat": 0, "lng": 0}',
  stars INTEGER NOT NULL CHECK (stars BETWEEN 1 AND 5),
  rating NUMERIC(3,1) NOT NULL CHECK (rating BETWEEN 1.0 AND 10.0),
  review_label VARCHAR(64) NOT NULL,
  reviews_count INTEGER NOT NULL DEFAULT 0,
  price_usd INTEGER NOT NULL,
  original_price_usd INTEGER NOT NULL,
  genius_level INTEGER NOT NULL DEFAULT 1,
  free_cancellation BOOLEAN NOT NULL DEFAULT TRUE,
  breakfast_included BOOLEAN NOT NULL DEFAULT FALSE,
  no_prepayment BOOLEAN NOT NULL DEFAULT TRUE,
  sustainable_level INTEGER NOT NULL DEFAULT 3,
  hero_image VARCHAR(255) NOT NULL,
  badges JSONB NOT NULL DEFAULT '[]',
  amenities JSONB NOT NULL DEFAULT '[]',
  description TEXT NOT NULL,
  rooms JSONB NOT NULL DEFAULT '[]',
  subscores JSONB NOT NULL DEFAULT '{"staff":9.8,"cleanliness":9.9,"location":9.7,"facilities":9.6,"comfort":9.8,"value":9.5}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Bookings Table (Stays, Flights, Flight+Hotel Packages, Car Rentals, Attractions, Airport Taxis)
CREATE TABLE IF NOT EXISTS bookings (
  booking_ref VARCHAR(32) PRIMARY KEY,
  pin_code VARCHAR(10) NOT NULL,
  booking_type VARCHAR(32) NOT NULL DEFAULT 'stay', -- 'stay', 'flight', 'package', 'car', 'attraction', 'taxi'
  item_id VARCHAR(64) NOT NULL,
  item_title VARCHAR(255) NOT NULL,
  location_label VARCHAR(255) NOT NULL,
  check_in DATE NOT NULL,
  check_out DATE,
  nights INTEGER NOT NULL DEFAULT 1,
  guests_summary VARCHAR(160) NOT NULL,
  room_or_tier VARCHAR(160) NOT NULL,
  guest_name VARCHAR(160) NOT NULL,
  guest_email VARCHAR(180) NOT NULL,
  guest_phone VARCHAR(64),
  special_requests TEXT,
  arrival_window VARCHAR(64),
  payment_method VARCHAR(64) NOT NULL DEFAULT 'Pay at Property',
  currency VARCHAR(12) NOT NULL DEFAULT 'USD',
  total_amount_usd NUMERIC(10,2) NOT NULL,
  genius_discount_usd NUMERIC(10,2) NOT NULL DEFAULT 0,
  status VARCHAR(32) NOT NULL DEFAULT 'Confirmed', -- 'Confirmed', 'Modified', 'Cancelled'
  metadata JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Verified Guest Reviews Table
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id VARCHAR(64) NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  reviewer_name VARCHAR(120) NOT NULL,
  reviewer_country VARCHAR(80) NOT NULL,
  traveler_type VARCHAR(64) NOT NULL DEFAULT 'Couple',
  room_stayed VARCHAR(140) NOT NULL,
  stay_month VARCHAR(48) NOT NULL,
  score NUMERIC(3,1) NOT NULL CHECK (score BETWEEN 1.0 AND 10.0),
  title VARCHAR(200) NOT NULL,
  positive_note TEXT NOT NULL,
  constructive_note TEXT,
  verified_booking BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. User Wishlists Table
CREATE TABLE IF NOT EXISTS wishlists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id VARCHAR(120) NOT NULL,
  property_id VARCHAR(64) NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(session_id, property_id)
);

CREATE INDEX IF NOT EXISTS idx_properties_city ON properties(LOWER(city));
CREATE INDEX IF NOT EXISTS idx_properties_category ON properties(category);
CREATE INDEX IF NOT EXISTS idx_bookings_email ON bookings(LOWER(guest_email));
CREATE INDEX IF NOT EXISTS idx_reviews_property ON reviews(property_id);
