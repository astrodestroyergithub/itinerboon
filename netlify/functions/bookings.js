import { getSql, corsHeaders } from './db.js';

export async function handler(event) {
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers: corsHeaders, body: '' };
  }

  try {
    const customConn = event.headers['x-neon-connection'] || null;
    const sql = getSql(customConn);

    if (event.httpMethod === 'GET') {
      const email = event.queryStringParameters?.email;
      const rows = email
        ? await sql`SELECT * FROM itinerboon_bookings WHERE LOWER(guest_email) = LOWER(${email}) ORDER BY created_at DESC`
        : await sql`SELECT * FROM itinerboon_bookings ORDER BY created_at DESC LIMIT 50`;

      return {
        statusCode: 200,
        headers: corsHeaders,
        body: JSON.stringify({ ok: true, source: 'neondb-serverless', table: 'itinerboon_bookings', bookings: rows })
      };
    }

    if (event.httpMethod === 'POST') {
      const b = JSON.parse(event.body || '{}');
      const bookingRef = b.booking_ref || `ITB-${Math.floor(100000 + Math.random() * 900000)}`;
      const pinCode = b.pin_code || String(Math.floor(1000 + Math.random() * 9000));

      const rows = await sql`
        INSERT INTO itinerboon_bookings (
          booking_ref, pin_code, booking_type, item_id, item_title, location_label,
          check_in, check_out, nights, guests_summary, room_or_tier,
          guest_name, guest_email, guest_phone, special_requests, arrival_window,
          payment_method, currency, total_amount_usd, genius_discount_usd, status, metadata
        ) VALUES (
          ${bookingRef}, ${pinCode}, ${b.booking_type || 'stay'}, ${b.item_id}, ${b.item_title}, ${b.location_label},
          ${b.check_in}, ${b.check_out || b.check_in}, ${b.nights || 1}, ${b.guests_summary}, ${b.room_or_tier},
          ${b.guest_name}, ${b.guest_email}, ${b.guest_phone || ''}, ${b.special_requests || ''}, ${b.arrival_window || '15:00 - 16:00'},
          ${b.payment_method || 'Pay at Property'}, ${b.currency || 'USD'}, ${b.total_amount_usd}, ${b.genius_discount_usd || 0},
          'Confirmed', ${JSON.stringify(b.metadata || {})}::jsonb
        )
        RETURNING *
      `;

      return {
        statusCode: 201,
        headers: corsHeaders,
        body: JSON.stringify({ ok: true, source: 'neondb-serverless', table: 'itinerboon_bookings', booking: rows[0] })
      };
    }

    if (event.httpMethod === 'PATCH') {
      const { booking_ref, status, check_in, check_out, guests_summary, special_requests } = JSON.parse(event.body || '{}');
      const rows = await sql`
        UPDATE itinerboon_bookings
        SET
          status = COALESCE(${status || null}, status),
          check_in = COALESCE(${check_in || null}, check_in),
          check_out = COALESCE(${check_out || null}, check_out),
          guests_summary = COALESCE(${guests_summary || null}, guests_summary),
          special_requests = COALESCE(${special_requests || null}, special_requests),
          updated_at = NOW()
        WHERE booking_ref = ${booking_ref}
        RETURNING *
      `;
      return {
        statusCode: 200,
        headers: corsHeaders,
        body: JSON.stringify({ ok: true, source: 'neondb-serverless', table: 'itinerboon_bookings', booking: rows[0] })
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
