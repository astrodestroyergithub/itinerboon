import { getSql, corsHeaders } from './db.js';

export async function handler(event) {
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers: corsHeaders, body: '' };
  }

  try {
    const customConn = event.headers['x-neon-connection'] || null;
    const sql = getSql(customConn);

    if (event.httpMethod === 'GET') {
      const propertyId = event.queryStringParameters?.property_id;
      const rows = propertyId
        ? await sql`SELECT * FROM reviews WHERE property_id = ${propertyId} ORDER BY created_at DESC`
        : await sql`SELECT * FROM reviews ORDER BY created_at DESC LIMIT 30`;

      return {
        statusCode: 200,
        headers: corsHeaders,
        body: JSON.stringify({ ok: true, source: 'neondb-serverless', reviews: rows })
      };
    }

    if (event.httpMethod === 'POST') {
      const r = JSON.parse(event.body || '{}');
      const inserted = await sql`
        INSERT INTO reviews (
          property_id, reviewer_name, reviewer_country, traveler_type,
          room_stayed, stay_month, score, title, positive_note, constructive_note
        ) VALUES (
          ${r.property_id}, ${r.reviewer_name}, ${r.reviewer_country || 'United States'},
          ${r.traveler_type || 'Couple'}, ${r.room_stayed || 'Deluxe Suite'},
          ${r.stay_month || 'October 2026'}, ${r.score || 9.5},
          ${r.title}, ${r.positive_note}, ${r.constructive_note || ''}
        )
        RETURNING *
      `;
      return {
        statusCode: 201,
        headers: corsHeaders,
        body: JSON.stringify({ ok: true, source: 'neondb-serverless', review: inserted[0] })
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
