-- =============================================================================
-- Itinerboon Travel Platform — Conflict-Free Standalone NeonDB PostgreSQL Script
-- Namespaced with `itinerboon_` prefix so existing tables (`properties`, etc.)
-- and indexes (`idx_properties_city`, etc.) in your database remain 100% untouched.
-- Safe to run multiple times (idempotent).
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Itinerboon Properties Table (Stays: Hotels, Resorts, Villas, Ryokans, Chalets)
CREATE TABLE IF NOT EXISTS itinerboon_properties (
  id VARCHAR(64) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  category VARCHAR(64) NOT NULL DEFAULT 'Resort',
  city VARCHAR(120) NOT NULL,
  country VARCHAR(120) NOT NULL,
  neighborhood VARCHAR(160) NOT NULL DEFAULT 'City Center',
  distance_from_center VARCHAR(80) NOT NULL DEFAULT '0.5 km from center',
  coordinates JSONB NOT NULL DEFAULT '{"lat": 0, "lng": 0}',
  stars INTEGER NOT NULL DEFAULT 5 CHECK (stars BETWEEN 1 AND 5),
  rating NUMERIC(3,1) NOT NULL DEFAULT 9.5 CHECK (rating BETWEEN 1.0 AND 10.0),
  review_label VARCHAR(64) NOT NULL DEFAULT 'Exceptional',
  reviews_count INTEGER NOT NULL DEFAULT 1,
  price_usd INTEGER NOT NULL DEFAULT 350,
  original_price_usd INTEGER NOT NULL DEFAULT 420,
  genius_level INTEGER NOT NULL DEFAULT 2,
  free_cancellation BOOLEAN NOT NULL DEFAULT TRUE,
  breakfast_included BOOLEAN NOT NULL DEFAULT TRUE,
  no_prepayment BOOLEAN NOT NULL DEFAULT TRUE,
  sustainable_level INTEGER NOT NULL DEFAULT 3,
  hero_image VARCHAR(255) NOT NULL DEFAULT 'assets/images/hero_mediterranean.jpg',
  badges JSONB NOT NULL DEFAULT '[]',
  amenities JSONB NOT NULL DEFAULT '[]',
  description TEXT NOT NULL DEFAULT '',
  rooms JSONB NOT NULL DEFAULT '[]',
  subscores JSONB NOT NULL DEFAULT '{"staff":9.8,"cleanliness":9.9,"location":9.7,"facilities":9.6,"comfort":9.8,"value":9.5}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Defensive column guarantees in case table was partially created earlier
ALTER TABLE itinerboon_properties
  ADD COLUMN IF NOT EXISTS category VARCHAR(64) NOT NULL DEFAULT 'Resort',
  ADD COLUMN IF NOT EXISTS neighborhood VARCHAR(160) NOT NULL DEFAULT 'City Center',
  ADD COLUMN IF NOT EXISTS distance_from_center VARCHAR(80) NOT NULL DEFAULT '0.5 km from center',
  ADD COLUMN IF NOT EXISTS coordinates JSONB NOT NULL DEFAULT '{"lat": 0, "lng": 0}',
  ADD COLUMN IF NOT EXISTS stars INTEGER NOT NULL DEFAULT 5,
  ADD COLUMN IF NOT EXISTS rating NUMERIC(3,1) NOT NULL DEFAULT 9.5,
  ADD COLUMN IF NOT EXISTS review_label VARCHAR(64) NOT NULL DEFAULT 'Exceptional',
  ADD COLUMN IF NOT EXISTS reviews_count INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS price_usd INTEGER NOT NULL DEFAULT 350,
  ADD COLUMN IF NOT EXISTS original_price_usd INTEGER NOT NULL DEFAULT 420,
  ADD COLUMN IF NOT EXISTS genius_level INTEGER NOT NULL DEFAULT 2,
  ADD COLUMN IF NOT EXISTS free_cancellation BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS breakfast_included BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS no_prepayment BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS sustainable_level INTEGER NOT NULL DEFAULT 3,
  ADD COLUMN IF NOT EXISTS hero_image VARCHAR(255) NOT NULL DEFAULT 'assets/images/hero_mediterranean.jpg',
  ADD COLUMN IF NOT EXISTS badges JSONB NOT NULL DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS amenities JSONB NOT NULL DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS description TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS rooms JSONB NOT NULL DEFAULT '[]',
  ADD COLUMN IF NOT EXISTS subscores JSONB NOT NULL DEFAULT '{"staff":9.8,"cleanliness":9.9,"location":9.7,"facilities":9.6,"comfort":9.8,"value":9.5}',
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- 2. Itinerboon Bookings Table (Stays, Flights, Packages, Car Rentals, Attractions, Taxis)
CREATE TABLE IF NOT EXISTS itinerboon_bookings (
  booking_ref VARCHAR(32) PRIMARY KEY,
  pin_code VARCHAR(10) NOT NULL,
  booking_type VARCHAR(32) NOT NULL DEFAULT 'stay',
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
  status VARCHAR(32) NOT NULL DEFAULT 'Confirmed',
  metadata JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Itinerboon Verified Guest Reviews Table
CREATE TABLE IF NOT EXISTS itinerboon_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id VARCHAR(64) NOT NULL REFERENCES itinerboon_properties(id) ON DELETE CASCADE,
  reviewer_name VARCHAR(120) NOT NULL,
  reviewer_country VARCHAR(80) NOT NULL DEFAULT 'United States',
  traveler_type VARCHAR(64) NOT NULL DEFAULT 'Couple',
  room_stayed VARCHAR(140) NOT NULL DEFAULT 'Luxury Suite',
  stay_month VARCHAR(48) NOT NULL DEFAULT 'October 2026',
  score NUMERIC(3,1) NOT NULL CHECK (score BETWEEN 1.0 AND 10.0),
  title VARCHAR(200) NOT NULL,
  positive_note TEXT NOT NULL,
  constructive_note TEXT,
  verified_booking BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Itinerboon User Wishlists Table
CREATE TABLE IF NOT EXISTS itinerboon_wishlists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id VARCHAR(120) NOT NULL,
  property_id VARCHAR(64) NOT NULL REFERENCES itinerboon_properties(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(session_id, property_id)
);

-- 5. Conflict-Free Namespaced Indexes
CREATE INDEX IF NOT EXISTS idx_itinerboon_properties_city ON itinerboon_properties(LOWER(city));
CREATE INDEX IF NOT EXISTS idx_itinerboon_properties_category ON itinerboon_properties(category);
CREATE INDEX IF NOT EXISTS idx_itinerboon_bookings_email ON itinerboon_bookings(LOWER(guest_email));
CREATE INDEX IF NOT EXISTS idx_itinerboon_reviews_property ON itinerboon_reviews(property_id);

-- 6. Initial Seed Data (Idempotent ON CONFLICT DO NOTHING)
INSERT INTO itinerboon_properties (
  id, title, category, city, country, neighborhood, distance_from_center,
  stars, rating, review_label, reviews_count, price_usd, original_price_usd,
  genius_level, free_cancellation, breakfast_included, no_prepayment, sustainable_level,
  hero_image, badges, amenities, description
) VALUES
  ('prop_santorini_azure', 'Azure Cliffside Infinity Resort & Spa', 'Resort', 'Santorini', 'Greece', 'Imerovigli Caldera Rim', '0.6 km from Oia footpath', 5, 9.9, 'Exceptional', 1420, 460, 575, 3, TRUE, TRUE, TRUE, 3, 'assets/images/hero_mediterranean.jpg', '["BoonGenius VIP","Free champagne breakfast"]'::jsonb, '["Infinity Pool","Spa & Wellness","Airport Shuttle","Michelin Dining"]'::jsonb, 'Perched high on the sun-drenched volcanic cliffs of Santorini with a heated horizon infinity pool.'),
  ('prop_maldives_lagoon', 'Coral Lagoon Overwater Villas & Reserve', 'Villa', 'Maldives', 'Maldives', 'Baa Atoll UNESCO Biosphere', '25-min scenic seaplane from Malé', 5, 9.8, 'Exceptional', 985, 640, 790, 3, TRUE, TRUE, TRUE, 3, 'assets/images/maldives_villa.jpg', '["Direct Lagoon Stairs","Private Infinity Plunge Pool"]'::jsonb, '["Infinity Pool","Spa & Wellness","Airport Shuttle","Private Sundeck"]'::jsonb, 'Crystal-clear turquoise lagoon waters in Baa Atoll with private infinity plunge pools.'),
  ('prop_paris_lumiere', 'Hôtel Lumière Champs-Élysées & Eiffel View', 'Boutique Hotel', 'Paris', 'France', '8th Arr. — Avenue Montaigne', '450 m from Eiffel Tower promenade', 5, 9.6, 'Exceptional', 2140, 390, 470, 2, TRUE, TRUE, TRUE, 3, 'assets/images/paris_suite.jpg', '["Direct Eiffel Tower View","Patisserie Breakfast"]'::jsonb, '["Michelin Dining","Spa & Wellness","Airport Shuttle","Pet Friendly"]'::jsonb, 'Classic Parisian Haussmann elegance with tall French doors opening to Eiffel Tower views.'),
  ('prop_swiss_matterhorn', 'Matterhorn Glass Thermal Spa & Alpine Resort', 'Chalet', 'Zermatt', 'Switzerland', 'Sunnegga Panorama Ridge', '300 m from Gornergrat Bahn', 5, 9.8, 'Exceptional', 1190, 510, 620, 2, TRUE, TRUE, TRUE, 3, 'assets/images/swiss_alps_spa.jpg', '["Heated 36°C Outdoor Infinity Pool","Direct Matterhorn View"]'::jsonb, '["Infinity Pool","Spa & Wellness","Ski Valet","Michelin Dining"]'::jsonb, 'Steaming mineral thermal waters gazing directly at the sunlit pyramid of the Matterhorn.'),
  ('prop_kyoto_ryokan', 'Arashiyama Cedar Pavilion & Koi Garden Ryokan', 'Ryokan', 'Kyoto', 'Japan', 'Arashiyama Bamboo Sanctuary', '5-min walk from Togetsukyo Bridge', 5, 9.9, 'Exceptional', 870, 430, 520, 3, TRUE, TRUE, TRUE, 3, 'assets/images/kyoto_ryokan.jpg', '["Private Hinoki Cypress Onsen","Kaiseki Breakfast"]'::jsonb, '["Spa & Wellness","Michelin Dining","Private Hinoki Bath","Zen Garden"]'::jsonb, 'Handcrafted cedar pavilion ryokan beside an emerald bamboo grove and koi reflection pond.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO itinerboon_bookings (
  booking_ref, pin_code, booking_type, item_id, item_title, location_label,
  check_in, check_out, nights, guests_summary, room_or_tier,
  guest_name, guest_email, payment_method, total_amount_usd, genius_discount_usd, status
) VALUES
  ('ITB-849201', '4928', 'stay', 'prop_santorini_azure', 'Azure Cliffside Infinity Resort & Spa', 'Santorini, Greece', '2026-11-12', '2026-11-16', 4, '2 adults · 1 room', 'Caldera Plunge Pool Villa', 'Aria Vance', 'aria.vance@itinerboon.com', 'Reserve Now, Pay at Property', 1680.00, 296.00, 'Confirmed'),
  ('ITB-730419', '8814', 'stay', 'prop_kyoto_ryokan', 'Arashiyama Cedar Pavilion & Koi Garden Ryokan', 'Kyoto, Japan', '2026-12-04', '2026-12-08', 4, '2 adults · 1 room', 'Hinoki Open-Air Onsen Pavilion', 'Aria Vance', 'aria.vance@itinerboon.com', 'Card Ending •••• 4242', 1590.00, 280.00, 'Confirmed')
ON CONFLICT (booking_ref) DO NOTHING;
