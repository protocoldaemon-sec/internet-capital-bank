import { Router, Request, Response } from 'express';
import { supabase } from '../services/supabase';
import { redisClient } from '../services/redis';
import { memoryEventEmitter } from '../services/memory/event-emitter';

const router = Router();

/**
 * GET /api/v1/health
 * Comprehensive health check endpoint
 * 
 * Returns:
 * - Service status
 * - Dependency health (Supabase, Redis)
 * - Query load metrics
 * - Connection pool status
 * - Event emitter status
 * 
 * Requirement 15.6, 13.7
 */
router.get('/', async (req: Request, res: Response) => {
  const healthStatus: any = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'ars-memory-service',
    version: '1.0.0',
    dependencies: {},
    metrics: {},
  };

  // Check Supabase connection
  try {
    const { error } = await supabase.from('wallet_registrations').select('address').limit(1);
    healthStatus.dependencies.supabase = {
      status: error ? 'unhealthy' : 'healthy',
      error: error?.message,
    };
  } catch (error: any) {
    healthStatus.dependencies.supabase = {
      status: 'unhealthy',
      error: error.message,
    };
    healthStatus.status = 'degraded';
  }

  // Check Redis connection
  try {
    await redisClient.ping();
    healthStatus.dependencies.redis = {
      status: 'healthy',
    };
  } catch (error: any) {
    healthStatus.dependencies.redis = {
      status: 'unhealthy',
      error: error.message,
    };
    healthStatus.status = 'degraded';
  }

  // Event emitter metrics
  healthStatus.metrics.eventEmitter = {
    subscriptionCount: memoryEventEmitter.getSubscriptionCount(),
  };

  // Overall status
  const allHealthy = Object.values(healthStatus.dependencies).every(
    (dep: any) => dep.status === 'healthy'
  );

  if (!allHealthy) {
    healthStatus.status = 'degraded';
    res.status(503);
  }

  res.json(healthStatus);
});

export default router;
