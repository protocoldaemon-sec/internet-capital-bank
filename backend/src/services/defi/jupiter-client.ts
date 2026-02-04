import axios, { AxiosInstance } from 'axios';
import { config } from '../../config';

export interface JupiterQuote {
  inputMint: string;
  inAmount: string;
  outputMint: string;
  outAmount: string;
  otherAmountThreshold: string;
  swapMode: string;
  slippageBps: number;
  priceImpactPct: number;
  routePlan: any[];
}

export interface JupiterSwapTransaction {
  swapTransaction: string;
  lastValidBlockHeight: number;
}

export interface JupiterTokenInfo {
  address: string;
  name: string;
  symbol: string;
  decimals: number;
  logoURI?: string;
  tags?: string[];
  daily_volume?: number;
}

export interface JupiterPriceData {
  id: string;
  mintSymbol: string;
  vsToken: string;
  vsTokenSymbol: string;
  price: number;
}

/**
 * Jupiter API Client
 * Provides swap aggregation, price data, and liquidity metrics
 */
export class JupiterClient {
  private client: AxiosInstance;
  private priceCache: Map<string, { price: number; timestamp: number }> = new Map();
  private readonly CACHE_TTL = 30 * 1000; // 30 seconds

  constructor() {
    this.client = axios.create({
      baseURL: config.apis.jupiterApiUrl,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    console.log('✅ Jupiter client initialized');
  }

  /**
   * Get quote for a swap
   */
  async getQuote(params: {
    inputMint: string;
    outputMint: string;
    amount: number;
    slippageBps?: number;
  }): Promise<JupiterQuote> {
    try {
      const response = await this.client.get('/quote', {
        params: {
          inputMint: params.inputMint,
          outputMint: params.outputMint,
          amount: params.amount,
          slippageBps: params.slippageBps || 50, // 0.5% default slippage
        },
      });

      return response.data;
    } catch (error) {
      console.error('Jupiter getQuote error:', error);
      throw new Error(`Failed to get Jupiter quote: ${error}`);
    }
  }

  /**
   * Get swap transaction
   */
  async getSwapTransaction(params: {
    quoteResponse: JupiterQuote;
    userPublicKey: string;
    wrapUnwrapSOL?: boolean;
  }): Promise<JupiterSwapTransaction> {
    try {
      const response = await this.client.post('/swap', {
        quoteResponse: params.quoteResponse,
        userPublicKey: params.userPublicKey,
        wrapUnwrapSOL: params.wrapUnwrapSOL ?? true,
      });

      return response.data;
    } catch (error) {
      console.error('Jupiter getSwapTransaction error:', error);
      throw new Error(`Failed to get swap transaction: ${error}`);
    }
  }

  /**
   * Get token price from Jupiter Price API
   */
  async getTokenPrice(mintAddress: string): Promise<number> {
    // Check cache
    const cached = this.priceCache.get(mintAddress);
    if (cached && Date.now() - cached.timestamp < this.CACHE_TTL) {
      return cached.price;
    }

    try {
      const response = await axios.get(`https://price.jup.ag/v4/price`, {
        params: {
          ids: mintAddress,
        },
      });

      const priceData = response.data.data[mintAddress];
      if (!priceData) {
        throw new Error(`Price not found for ${mintAddress}`);
      }

      const price = priceData.price;

      // Cache the price
      this.priceCache.set(mintAddress, { price, timestamp: Date.now() });

      return price;
    } catch (error) {
      console.error('Jupiter getTokenPrice error:', error);
      throw new Error(`Failed to get token price: ${error}`);
    }
  }

  /**
   * Get multiple token prices
   */
  async getTokenPrices(mintAddresses: string[]): Promise<Record<string, number>> {
    try {
      const response = await axios.get(`https://price.jup.ag/v4/price`, {
        params: {
          ids: mintAddresses.join(','),
        },
      });

      const prices: Record<string, number> = {};
      for (const [mint, data] of Object.entries(response.data.data)) {
        prices[mint] = (data as any).price;

        // Cache each price
        this.priceCache.set(mint, {
          price: (data as any).price,
          timestamp: Date.now(),
        });
      }

      return prices;
    } catch (error) {
      console.error('Jupiter getTokenPrices error:', error);
      throw new Error(`Failed to get token prices: ${error}`);
    }
  }

  /**
   * Get token list
   */
  async getTokenList(): Promise<JupiterTokenInfo[]> {
    try {
      const response = await axios.get('https://token.jup.ag/all');
      return response.data;
    } catch (error) {
      console.error('Jupiter getTokenList error:', error);
      throw new Error(`Failed to get token list: ${error}`);
    }
  }

  /**
   * Get swap volume for a token pair (24h)
   */
  async getSwapVolume(inputMint: string, outputMint: string): Promise<number> {
    try {
      // Note: Jupiter doesn't have a direct volume API
      // This would need to be calculated from historical swap data
      // For now, return 0 as placeholder
      console.warn('Jupiter swap volume API not available, returning 0');
      return 0;
    } catch (error) {
      console.error('Jupiter getSwapVolume error:', error);
      return 0;
    }
  }

  /**
   * Calculate price impact for a swap
   */
  async calculatePriceImpact(params: {
    inputMint: string;
    outputMint: string;
    amount: number;
  }): Promise<number> {
    try {
      const quote = await this.getQuote(params);
      return quote.priceImpactPct;
    } catch (error) {
      console.error('Jupiter calculatePriceImpact error:', error);
      throw new Error(`Failed to calculate price impact: ${error}`);
    }
  }

  /**
   * Get best route for a swap
   */
  async getBestRoute(params: {
    inputMint: string;
    outputMint: string;
    amount: number;
  }): Promise<any[]> {
    try {
      const quote = await this.getQuote(params);
      return quote.routePlan;
    } catch (error) {
      console.error('Jupiter getBestRoute error:', error);
      throw new Error(`Failed to get best route: ${error}`);
    }
  }

  /**
   * Get SOL/USDC price
   */
  async getSOLUSDCPrice(): Promise<number> {
    const SOL_MINT = 'So11111111111111111111111111111111111111112';
    return this.getTokenPrice(SOL_MINT);
  }

  /**
   * Get liquidity for a token pair
   */
  async getLiquidity(inputMint: string, outputMint: string): Promise<{
    available: boolean;
    routes: number;
  }> {
    try {
      const quote = await this.getQuote({
        inputMint,
        outputMint,
        amount: 1000000, // 1 USDC equivalent
      });

      return {
        available: true,
        routes: quote.routePlan.length,
      };
    } catch (error) {
      return {
        available: false,
        routes: 0,
      };
    }
  }
}

// Singleton instance
let jupiterClient: JupiterClient | null = null;

/**
 * Get or create Jupiter client instance
 */
export function getJupiterClient(): JupiterClient {
  if (!jupiterClient) {
    jupiterClient = new JupiterClient();
  }
  return jupiterClient;
}
