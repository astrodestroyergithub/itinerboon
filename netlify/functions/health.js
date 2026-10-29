import { getSql, corsHeaders } from './db.js';

export async function handler(event) {
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers: corsHeaders, body: '' };
  }

  const startedAt = Date.now();
  try {
    const customConn = event.headers['x-neon-connection'] || null;
    const sql = getSql(customConn);
    const result = await sql`SELECT version() AS pg_version, current_database() AS db_name, NOW() AS server_time`;
    const latencyMs = Date.now() - startedAt;

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        ok: true,
        engine: 'Neon Serverless PostgreSQL',
        latency_ms: latencyMs,
        info: result[0]
      })
    };
  } catch (err) {
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        ok: false,
        engine: 'NeonDB Local/Hybrid Fallback Active',
        message: err.message
      })
    };
  }
}
