import { getSql, corsHeaders } from './db.js';

export async function handler(event) {
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers: corsHeaders, body: '' };
  }

  try {
    const customConn = event.headers['x-neon-connection'] || null;
    const sql = getSql(customConn);

    if (event.httpMethod === 'GET') {
      const params = event.queryStringParameters || {};
      const { city, category, maxPrice, minRating } = params;

      let rows = await sql`
        SELECT * FROM properties
        ORDER BY rating DESC, reviews_count DESC
      `;

      if (city) {
        const q = city.toLowerCase();
        rows = rows.filter(
          (r) =>
            r.city.toLowerCase().includes(q) ||
            r.country.toLowerCase().includes(q) ||
            r.title.toLowerCase().includes(q)
        );
      }
      if (category && category !== 'all') {
        rows = rows.filter((r) => r.category.toLowerCase() === category.toLowerCase());
      }
      if (maxPrice) {
        rows = rows.filter((r) => Number(r.price_usd) <= Number(maxPrice));
      }
      if (minRating) {
        rows = rows.filter((r) => Number(r.rating) >= Number(minRating));
      }

      return {
        statusCode: 200,
        headers: corsHeaders,
        body: JSON.stringify({ ok: true, source: 'neondb-serverless', count: rows.length, properties: rows })
      };
    }

    if (event.httpMethod === 'POST') {
      const payload = JSON.parse(event.body || '{}');
      const {
        id,
        title,
        category = 'Boutique Hotel',
        city,
        country,
        neighborhood = 'City Center',
        distance_from_center = '0.8 km from center',
        stars = 5,
        rating = 9.4,
        review_label = 'Wonderful',
        reviews_count = 1,
        price_usd,
        original_price_usd,
        genius_level = 2,
        free_cancellation = true,
        breakfast_included = true,
        no_prepayment = true,
        hero_image,
        badges = ['New on Itinerboon', 'BoonGenius Partner'],
        amenities = ['Free High-Speed WiFi', 'Infinity Pool', 'Airport Transfer', '24/7 Concierge'],
        description = 'Newly listed luxury partner property on Itinerboon synced with NeonDB.'
      } = payload;

      const propId = id || `prop_${Date.now()}`;
      const inserted = await sql`
        INSERT INTO properties (
          id, title, category, city, country, neighborhood, distance_from_center,
          stars, rating, review_label, reviews_count, price_usd, original_price_usd,
          genius_level, free_cancellation, breakfast_included, no_prepayment,
          hero_image, badges, amenities, description
        ) VALUES (
          ${propId}, ${title}, ${category}, ${city}, ${country}, ${neighborhood}, ${distance_from_center},
          ${stars}, ${rating}, ${review_label}, ${reviews_count}, ${price_usd}, ${original_price_usd || Math.round(price_usd * 1.2)},
          ${genius_level}, ${free_cancellation}, ${breakfast_included}, ${no_prepayment},
          ${hero_image}, ${JSON.stringify(badges)}::jsonb, ${JSON.stringify(amenities)}::jsonb, ${description}
        )
        RETURNING *
      `;

      return {
        statusCode: 201,
        headers: corsHeaders,
        body: JSON.stringify({ ok: true, source: 'neondb-serverless', property: inserted[0] })
      };
    }

    return { statusCode: 405, headers: corsHeaders, body: JSON.stringify({ error: 'Method Not Allowed' }) };
  } catch (err) {
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ ok: false, error: err.message })
    };
  }
}
