import dotenv from 'dotenv';

dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '4000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  
  supabase: {
    url: process.env.SUPABASE_URL || 'http://localhost:8000',
    anonKey: process.env.SUPABASE_ANON_KEY || '',
    serviceKey: process.env.SUPABASE_SERVICE_KEY || '',
  },
  
  redis: {
    url: process.env.REDIS_URL || 'redis://localhost:6379',
    password: process.env.REDIS_PASSWORD || '',
  },
  
  solana: {
    rpcUrl: process.env.SOLANA_RPC_URL || 'https://api.devnet.solana.com',
    network: process.env.SOLANA_NETWORK || 'devnet',
  },
  
  heliusApiKey: process.env.HELIUS_API_KEY || '',
  
  oracles: {
    pythProgramId: process.env.PYTH_PROGRAM_ID || 'gSbePebfvPy7tRqimPoVecS2UsBvYv46ynrzWocc92s',
    switchboardProgramId: process.env.SWITCHBOARD_PROGRAM_ID || 'SW1TCH7qEPTdLsDHRgPuMQjbQxKdH2aBStViMFnt64f',
  },
  
  apis: {
    birdeyeApiKey: process.env.BIRDEYE_API_KEY || '',
    jupiterApiUrl: process.env.JUPITER_API_URL || 'https://quote-api.jup.ag/v6',
    meteoraApiUrl: process.env.METEORA_API_URL || 'https://dlmm-api.meteora.ag',
    kaminoApiUrl: process.env.KAMINO_API_URL || 'https://api.kamino.finance',
    magicRouterUrl: process.env.MAGIC_ROUTER_URL || 'https://router.magicblock.gg',
    openRouterApiKey: process.env.OPENROUTER_API_KEY || '',
    openRouterReferer: process.env.OPENROUTER_REFERER || 'https://internet-capital-bank.com',
  },
  
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10),
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
  },
};
