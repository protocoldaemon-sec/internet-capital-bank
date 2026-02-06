import express, { Application } from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import { config } from './config';
import { metricsMiddleware } from './middleware/metrics-middleware';

// Import routes
import iliRoutes from './routes/ili';
import icrRoutes from './routes/icr';
import proposalRoutes from './routes/proposals';
import reserveRoutes from './routes/reserve';
import revenueRoutes from './routes/revenue';
import agentRoutes from './routes/agents';
import privacyRoutes from './routes/privacy';
import complianceRoutes from './routes/compliance';
import memoryRoutes from './routes/memory';
import healthRoutes from './routes/health';
import metricsRoutes from './routes/metrics';

export function createApp(): Application {
  const app = express();

  // Middleware
  app.use(cors());
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  // Metrics tracking middleware
  app.use(metricsMiddleware);

  // Rate limiting
  const limiter = rateLimit({
    windowMs: config.rateLimit.windowMs,
    max: config.rateLimit.maxRequests,
    message: 'Too many requests from this IP, please try again later.',
  });
  app.use('/api/', limiter);

  // Health check
  app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
  });

  // API routes
  app.use('/api/v1/ili', iliRoutes);
  app.use('/api/v1/icr', icrRoutes);
  app.use('/api/v1/proposals', proposalRoutes);
  app.use('/api/v1/reserve', reserveRoutes);
  app.use('/api/v1/revenue', revenueRoutes);
  app.use('/api/v1/agents', agentRoutes);
  
  // Privacy routes (Phase 1 & 2: Shielded Transfers, MEV Protection)
  if (config.privacy?.enabled) {
    app.use('/api/v1/privacy', privacyRoutes);
  }

  // Compliance routes (Phase 3: Compliance Layer)
  if (config.privacy?.enabled) {
    app.use('/api/v1/compliance', complianceRoutes);
  }

  // Memory routes (Solder Cortex integration)
  app.use('/api/v1/memory', memoryRoutes);

  // Health check routes
  app.use('/api/v1/health', healthRoutes);

  // Metrics endpoint (Prometheus)
  app.use('/metrics', metricsRoutes);

  // Error handling middleware
  app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
    console.error('Error:', err);
    res.status(err.status || 500).json({
      error: err.message || 'Internal server error',
    });
  });

  // 404 handler
  app.use((req, res) => {
    res.status(404).json({ error: 'Not found' });
  });

  return app;
}
