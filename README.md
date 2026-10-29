# Itinerboon — Global Travel & Hospitality Platform (Netlify + NeonDB)

**Itinerboon** is a full-featured, sun-drenched, ultra-responsive global travel and hospitality booking platform inspired by Booking.com, engineered for instant deployment on **Netlify** with **NeonDB Serverless PostgreSQL**.

## ✨ Key Platform Highlights
- **6 Complete Booking Verticals**:
  1. **Stays**: Luxury resorts, overwater villas, boutique hotels, Alpine chalets, Kyoto ryokans, and city penthouses with HD photography.
  2. **Flights**: Round-trip, one-way, and multi-city flight search with cabin classes, baggage breakdown, direct/stop filters, and instant ticket issuance.
  3. **Flight + Hotel Bundles**: Dynamic vacation package builder combining flights and stays with automatic bundle savings.
  4. **Car Rentals**: Global fleet from electric hatchbacks to luxury SUVs with full insurance protection tiers and pickup/drop-off scheduling.
  5. **Attractions & Tours**: Skip-the-line landmarks, sunset yacht cruises, culinary tours, and guided excursions.
  6. **Airport Taxis**: Private flight-tracked airport transfers with Meet & Greet service and vehicle tier selection.
- **Iconic Booking.com Features**:
  - **BoonGenius Loyalty Program** (Levels 1, 2 & 3) with automatic 10%–20% member discounts, complimentary breakfast, and room upgrades.
  - **Interactive Room Selection Matrix** inside property detail modals with multi-room quantity selectors, cancellation policies, and real-time tax calculation.
  - **Interactive Split-Map View** with live price pins, neighborhood distance badges, and side-by-side **Property Comparison Matrix**.
  - **Multi-Currency & Multi-Language Switcher** (`USD`, `EUR`, `GBP`, `INR`, `JPY`, `AED`, `CHF`).
  - **NeonDB Cloud Studio & Live SQL Inspector** built right into the header so you can test serverless database queries, inspect live SQL logs, or connect your Neon PostgreSQL instance directly.

## 📁 Project Structure
```text
itinerboon/
├── index.html                  # Complete responsive frontend application
├── favicon.svg                 # Custom SVG emblem in root directory
├── netlify.toml                # Netlify build, redirects (/api/* -> functions), & headers
├── package.json                # @neondatabase/serverless & @netlify/functions
├── .env.example                # Environment variable template for DATABASE_URL
├── assets/
│   └── images/                 # 10 High-Definition (HD) destination & property photographs
├── db/
│   └── schema.sql              # Complete PostgreSQL schema & indexes for NeonDB
└── netlify/
    └── functions/
        ├── db.js               # Neon serverless connection pool helper
        ├── health.js           # GET /api/health — NeonDB latency & version check
        ├── properties.js       # GET / POST /api/properties — Property catalog & host portal
        ├── bookings.js         # GET / POST / PATCH /api/bookings — Reservations & cancellations
        └── reviews.js          # GET / POST /api/reviews — Verified guest reviews
```

## 🚀 Deploying to Netlify + NeonDB in 3 Minutes
1. **Create a NeonDB Project**:
   - Visit [https://console.neon.tech](https://console.neon.tech) and create a new PostgreSQL database named `itinerboon`.
   - Open the **SQL Editor** in Neon Console and run the contents of `db/schema.sql`.
2. **Connect to Netlify**:
   - Drag and drop this folder into Netlify, or push to GitHub/GitLab and import into Netlify.
   - In **Netlify Site Configuration → Environment Variables**, add:
     - `DATABASE_URL` = `postgresql://user:pass@ep-...pooler.us-east-2.aws.neon.tech/itinerboon?sslmode=require`
   - Alternatively, run `npx netlify-cli env:set DATABASE_URL "postgresql://..."` and `npx netlify-cli deploy --prod`.
3. **Interactive In-App NeonDB Studio**:
   - Click the **"NeonDB Connected"** badge in the top navigation bar at any time to view live SQL query logs, copy the DDL schema, or test a custom Neon connection string directly from the browser.
