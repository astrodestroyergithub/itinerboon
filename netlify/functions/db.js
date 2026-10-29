import { neon, neonConfig } from '@neondatabase/serverless';

// Enable connection caching for low-latency Netlify serverless execution
neonConfig.fetchConnectionCache = true;

export function getSql(customConnectionString = null) {
  const connectionString = customConnectionString || process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error(
      'Missing DATABASE_URL environment variable. Configure your NeonDB pooled connection string in Netlify Site Settings -> Environment Variables.'
    );
  }
  return neon(connectionString);
}

export const corsHeaders = {
  'Access-Control-Allow-Origin': process.env.ALLOWED_ORIGIN || '*',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Neon-Connection',
  'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
  'Content-Type': 'application/json'
};
