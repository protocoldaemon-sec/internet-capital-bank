import { Request, Response, NextFunction } from 'express';
import { metricsService } from '../services/memory/metrics';

/**
 * Middleware to track request metrics
 * 
 * Tracks:
 * - Request count by endpoint and status
 * - Request duration
 * - Error rate
 * 
 * Requirements: 15.2, 15.3
 */
export function metricsMiddleware(req: Request, res: Response, next: NextFunction): void {
  const startTime = Date.now();
  const endpoint = req.path;

  // Track response
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    const success = res.statusCode < 400;

    metricsService.recordQuery(endpoint, duration, success);

    // Log slow queries (> 1 second)
    if (duration > 1000) {
      console.warn(`[Metrics] Slow query detected: ${req.method} ${endpoint} took ${duration}ms`);
      metricsService.incrementCounter('memory_slow_queries_total', 1, { endpoint });
    }
  });

  next();
}
