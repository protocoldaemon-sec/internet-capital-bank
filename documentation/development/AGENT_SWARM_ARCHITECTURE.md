# Internet Capital Bank - Agent Swarm Architecture

## Overview

ICB implements a **hierarchical multi-agent swarm system** using OpenClaw for autonomous monetary policy management. The system coordinates 10 specialized agents that collaborate through message-passing, consensus voting, and workflow orchestration.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    ICB Orchestrator                          │
│              (Master Coordinator)                            │
└──────────────────┬──────────────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
   ┌────▼────┐          ┌────▼────┐
   │ Policy  │          │ Oracle  │
   │ Agent   │◄────────►│ Agent   │
   └────┬────┘          └────┬────┘
        │                    │
   ┌────▼────┐          ┌────▼────┐
   │  DeFi   │          │  Risk   │
   │ Agent   │◄────────►│ Agent   │
   └────┬────┘          └────┬────┘
        │                    │
   ┌────▼────┐          ┌────▼────┐
   │Governance│         │Execution│
   │ Agent   │◄────────►│ Agent   │
   └────┬────┘          └────┬────┘
        │                    │
   ┌────▼────┐          ┌────▼────┐
   │ Payment │          │Monitoring│
   │ Agent   │          │ Agent   │
   └─────────┘          └────┬────┘
                             │
                        ┌────▼────┐
                        │Learning │
                        │ Agent   │
                        └─────────┘
```

## Agent Roles

### 1. **ICB Orchestrator** (Coordinator)
**Role**: Master coordinator for all agents

**Responsibilities**:
- Task delegation to specialist agents
- Result aggregation from multiple agents
- Conflict resolution between agents
- Priority management for workflows
- System-wide health monitoring

**Capabilities**:
- Workflow execution
- Consensus coordination
- Message routing
- Approval management

---

### 2. **Policy Agent** (Specialist)
**Role**: Monetary policy analysis and recommendation

**Responsibilities**:
- Calculate ILI (Internet Liquidity Index)
- Analyze market conditions with AI
- Recommend policy actions (mint/burn/rebalance)
- Forecast economic trends
- Scenario modeling

**Tools**:
- OpenRouter AI (Claude Sonnet 4)
- Historical data query
- Market sentiment analysis

**Collaborates With**: Oracle Agent, Risk Agent, Execution Agent

**AI Use Cases**:
```typescript
// ILI trend analysis
const analysis = await policyAgent.analyzeWithAI({
  market_data: currentMarket,
  historical_ili: last24Hours
});

// Policy recommendation
const recommendation = await policyAgent.recommendPolicy({
  ili: 100,
  icr: 85,
  vhr: 175,
  market_conditions: 'volatile'
});
```

---

### 3. **Oracle Agent** (Specialist)
**Role**: Multi-source oracle data aggregation

**Responsibilities**:
- Aggregate prices from Pyth, Switchboard, Birdeye
- Tri-source median calculation
- Outlier detection (>2σ)
- Oracle health monitoring
- Manipulation detection

**Tools**:
- Pyth client
- Switchboard client
- Birdeye client
- Helius RPC

**Update Frequency**: Every 5 minutes

**Collaborates With**: Policy Agent, Risk Agent

---

### 4. **DeFi Agent** (Specialist)
**Role**: DeFi protocol integration and yield optimization

**Responsibilities**:
- Execute swaps via Jupiter
- Manage liquidity on Meteora
- Optimize lending on Kamino
- Use MagicBlock ER for high-frequency ops
- Track protocol TVL/APY

**Tools**:
- Jupiter client (Ultra API v3)
- Meteora client (DLMM)
- Kamino client (lending)
- MagicBlock client (ER)

**Collaborates With**: Execution Agent, Risk Agent

---

### 5. **Governance Agent** (Specialist)
**Role**: Futarchy governance and proposal management

**Responsibilities**:
- Create and manage proposals
- Aggregate votes from agents
- Verify agent signatures (Ed25519)
- Enforce 24h execution delay
- Implement slashing for failed predictions

**Tools**:
- OpenRouter AI (proposal analysis)
- Supabase client
- Solana program client

**Collaborates With**: Policy Agent, Risk Agent, Execution Agent

**AI Use Cases**:
```typescript
// Analyze proposal quality
const analysis = await governanceAgent.analyzeProposal({
  proposalType: 'mint',
  proposalData: { amount: 1000000 },
  currentState: { ili: 100, vhr: 180 }
});
// Returns: { analysis: "...", recommendation: "approve" | "reject" }
```

---

### 6. **Risk Agent** (Specialist)
**Role**: Risk assessment and circuit breaker management

**Responsibilities**:
- Monitor VHR (Vault Health Ratio)
- Detect anomalies in metrics
- Assess systemic risks
- Trigger circuit breakers
- Stress testing with AI

**Tools**:
- OpenRouter AI (risk modeling)
- Oracle aggregator
- Reserve vault client

**Thresholds**:
- VHR Critical: 150%
- VHR Warning: 175%
- Oracle Health Min: 80%

**Collaborates With**: Policy Agent, Oracle Agent, Execution Agent

---

### 7. **Execution Agent** (Specialist)
**Role**: Transaction execution and state management

**Responsibilities**:
- Build and sign transactions
- Execute on-chain operations
- Manage MagicBlock ER sessions
- Handle transaction retries
- Commit ephemeral state to base layer

**Tools**:
- Solana Web3.js
- MagicBlock client
- Helius Sender (priority fees)

**Collaborates With**: Policy Agent, DeFi Agent, Governance Agent

---

### 8. **Payment Agent** (Specialist)
**Role**: x402 micropayment and budget management

**Responsibilities**:
- Execute x402 USDC payments
- Track spending budgets
- Optimize payment costs
- Handle payment retries
- Verify on-chain payments

**Tools**:
- x402 client
- Solana Web3.js

**Budget**:
- Daily Limit: 10 USDC
- Per Request Max: 0.1 USDC
- Currency: USDC (SPL)

**Collaborates With**: Oracle Agent, Policy Agent

---

### 9. **Monitoring Agent** (Specialist)
**Role**: System health monitoring and alerting

**Responsibilities**:
- Track agent health
- Monitor API latencies
- Aggregate error logs
- Send alerts (Discord, email)
- Update real-time dashboards

**Tools**:
- Redis client
- Supabase client
- WebSocket server

**Check Interval**: Every 1 minute

**Collaborates With**: ICB Orchestrator

---

### 10. **Learning Agent** (Specialist)
**Role**: Machine learning and strategy optimization

**Responsibilities**:
- Analyze historical performance
- Learn from past decisions
- Optimize policy strategies
- Pattern recognition with AI
- Generate improvement recommendations

**Tools**:
- OpenRouter AI (pattern recognition)
- Supabase client
- Historical data query

**Training Frequency**: Daily

**Collaborates With**: Policy Agent, Risk Agent

---

## Communication Protocol

### Message Format
```typescript
interface AgentMessage {
  type: string;                    // Message type
  from: string;                    // Sender agent ID
  to: string;                      // Recipient agent ID
  payload: any;                    // Message data
  timestamp: number;               // Unix timestamp
  priority: 'low' | 'normal' | 'high' | 'critical';
  correlationId?: string;          // For tracking workflows
}
```

### Message Types
- `action-request` - Request agent to perform action
- `agent-response` - Response from agent
- `approval-request` - Request approval for action
- `consensus-vote` - Request vote on decision
- `alert` - Send alert to orchestrator
- `workflow-request` - Request workflow execution

### Communication Channels (Redis Pub/Sub)
- `icb:orchestrator` - Orchestrator channel
- `icb:policy` - Policy agent channel
- `icb:oracle` - Oracle agent channel
- `icb:defi` - DeFi agent channel
- `icb:governance` - Governance agent channel
- `icb:risk` - Risk agent channel
- `icb:execution` - Execution agent channel
- `icb:payment` - Payment agent channel
- `icb:monitoring` - Monitoring agent channel
- `icb:learning` - Learning agent channel

---

## Workflows

### 1. ILI Update Workflow
**Trigger**: Cron (every 5 minutes)

**Steps**:
1. Oracle Agent: Aggregate prices (SOL, USDC, mSOL)
2. DeFi Agent: Fetch protocol metrics (Jupiter, Meteora, Kamino)
3. Policy Agent: Calculate ILI from aggregated data
4. Monitoring Agent: Update dashboard with new ILI

**Duration**: ~10 seconds

---

### 2. Policy Execution Workflow
**Trigger**: Event (proposal-passed)

**Steps**:
1. Governance Agent: Verify proposal validity
2. Risk Agent: Assess execution risk
3. Execution Agent: Execute policy (requires Risk Agent approval)
4. Monitoring Agent: Log execution result

**Duration**: ~30 seconds

---

### 3. Circuit Breaker Workflow
**Trigger**: Event (vhr-critical)

**Priority**: Critical

**Steps**:
1. Risk Agent: Assess severity
2. Execution Agent: Activate circuit breaker on-chain
3. Monitoring Agent: Send critical alert (Discord, email)

**Duration**: ~5 seconds

---

### 4. Vault Rebalance Workflow
**Trigger**: Cron (every 6 hours)

**Steps**:
1. Oracle Agent: Get current asset prices
2. DeFi Agent: Calculate optimal allocation
3. Risk Agent: Verify safe rebalance (approval required)
4. Execution Agent: Execute rebalance via Jupiter/Meteora

**Duration**: ~60 seconds

---

### 5. AI Policy Recommendation Workflow
**Trigger**: Cron (daily at midnight)

**Steps**:
1. Oracle Agent: Get 24h market data
2. Policy Agent: Analyze with AI (OpenRouter)
3. Learning Agent: Optimize recommendation based on past performance
4. Governance Agent: Create proposal from recommendation

**Duration**: ~120 seconds

---

## Consensus Mechanism

### Weighted Voting
Each agent has a weight based on expertise:

| Agent | Weight | Rationale |
|-------|--------|-----------|
| Policy Agent | 3 | Core monetary policy decisions |
| Risk Agent | 3 | Critical safety decisions |
| Oracle Agent | 2 | Data quality expertise |
| DeFi Agent | 2 | Protocol integration expertise |
| Governance Agent | 2 | Governance expertise |
| Execution Agent | 1 | Execution specialist |
| Payment Agent | 1 | Payment specialist |
| Monitoring Agent | 1 | Monitoring specialist |
| Learning Agent | 1 | Learning specialist |

**Quorum**: 60% of weighted votes

**Timeout**: 30 seconds

**Example**:
```
Total Weight: 16
Approval Weight: 10 (Policy: 3, Risk: 3, Oracle: 2, DeFi: 2)
Consensus: 10/16 = 62.5% ≥ 60% → APPROVED
```

---

## AI Integration

### OpenRouter Models Used
- **Claude Sonnet 4** - Primary model for all agents
- **GPT-4 Turbo** - Backup model
- **Mixtral 8x7B** - Cost-optimized model

### AI Use Cases

#### 1. ILI Trend Analysis
```typescript
const analysis = await openRouter.analyzeILI({
  currentILI: 100,
  historicalILI: [95, 98, 100],
  marketData: { tvl: 1000000, apy: 15 }
});
```

#### 2. Policy Recommendation
```typescript
const recommendation = await openRouter.generatePolicyRecommendation({
  ili: 100,
  icr: 85,
  vhr: 175,
  marketConditions: 'volatile'
});
```

#### 3. Proposal Analysis
```typescript
const analysis = await openRouter.analyzeProposal({
  proposalType: 'mint',
  proposalData: { amount: 1000000 },
  currentState: { ili: 100, vhr: 180 }
});
```

#### 4. Risk Modeling
```typescript
const riskScore = await openRouter.assessRisk({
  vhr: 160,
  oracleHealth: 0.85,
  marketVolatility: 0.3
});
```

### Cost Tracking
All AI calls are tracked via OpenRouter client:
```typescript
const stats = openRouter.getCostStats();
// { totalCost: 0.15, requestCount: 50, avgCostPerRequest: 0.003 }
```

---

## x402 Payment Integration

### Payment Flows

#### 1. Oracle Query Payment
```typescript
// Oracle agent requests premium data
const result = await x402Client.requestWithPayment({
  url: 'https://api.birdeye.so/premium/price',
  payer: agentKeypair
});
// Automatically handles 402 response and USDC payment
```

#### 2. AI API Payment
```typescript
// Policy agent pays for AI analysis
const result = await x402Client.requestWithPayment({
  url: 'https://openrouter.ai/api/v1/chat/completions',
  payer: agentKeypair,
  data: { model: 'claude-sonnet-4', messages: [...] }
});
```

#### 3. ER Session Payment
```typescript
// Execution agent pays for MagicBlock ER session
const result = await x402Client.makePayment({
  amount: 20000, // 0.02 USDC
  recipient: 'ERSessionVault...',
  payer: agentKeypair
});
```

### Budget Management
```typescript
// Payment agent tracks spending
const budget = x402Client.getBudget();
// { total: 10000000, spent: 150000, remaining: 9850000 }

// Alert if budget low
if (budget.remaining < budget.total * 0.1) {
  await monitoringAgent.sendAlert({
    severity: 'high',
    title: 'Low Payment Budget',
    description: `Only ${budget.remaining / 1000000} USDC remaining`
  });
}
```

---

## MagicBlock ER Integration

### High-Frequency Operations

#### 1. ILI Calculation (Every 5 min)
```typescript
// Delegate ILI account to ER
const session = await magicBlockClient.createSession({
  accounts: [iliAccount],
  payer: executionAgent.keypair,
  duration: 3600 // 1 hour
});

// Update ILI on ER (sub-second)
await magicBlockClient.sendTransaction({
  transaction: updateILITx,
  sessionId: session.sessionId
});

// Commit to base layer every hour
await magicBlockClient.commitSession(session.sessionId);
```

#### 2. Reserve Rebalancing
```typescript
// Use ER for high-frequency rebalancing
const session = await magicBlockClient.createSession({
  accounts: [vaultAccount, jupiterAccount],
  payer: executionAgent.keypair
});

// Execute multiple swaps on ER
for (const swap of swaps) {
  await magicBlockClient.sendTransaction({
    transaction: swap,
    sessionId: session.sessionId
  });
}

// Commit final state
await magicBlockClient.commitSession(session.sessionId);
```

---

## Monitoring & Alerts

### Metrics Tracked
- Agent response time
- Message queue depth
- Consensus time
- Workflow success rate
- API call count
- Error rate
- Cost per operation

### Alert Levels

#### Critical
- Agent down
- Circuit breaker activated
- VHR < 150%
- Oracle health < 50%

**Notification**: Discord + Email

#### High
- Consensus timeout
- Workflow failed
- Budget low (< 10%)
- Oracle health < 80%

**Notification**: Discord

#### Medium
- High error rate (> 5%)
- Slow response time (> 5s)
- High API costs

**Notification**: Discord

---

## Deployment

### Development
```bash
# Start Redis
docker-compose up redis

# Start orchestrator
npm run agent:orchestrator

# Start individual agents
npm run agent:policy
npm run agent:oracle
npm run agent:defi
# ... etc
```

### Production
```bash
# Use PM2 for process management
pm2 start ecosystem.config.js

# Monitor agents
pm2 monit

# View logs
pm2 logs icb-orchestrator
```

### Docker Compose
```yaml
services:
  orchestrator:
    build: .
    command: npm run agent:orchestrator
    depends_on:
      - redis
      - supabase
  
  policy-agent:
    build: .
    command: npm run agent:policy
    depends_on:
      - redis
  
  # ... other agents
```

---

## Security

### Agent Authentication
- Each agent has unique Ed25519 keypair
- Messages signed with agent private key
- Orchestrator verifies signatures

### Access Control
- Agents can only execute approved actions
- Critical actions require multi-agent approval
- Circuit breaker can halt all operations

### Budget Limits
- Daily spending limits per agent
- Per-request payment caps
- Automatic budget alerts

---

## Future Enhancements

### Phase 2
- [ ] Add more specialized agents (Liquidation Agent, Arbitrage Agent)
- [ ] Implement agent reputation system
- [ ] Add agent performance metrics
- [ ] Implement agent slashing for poor performance

### Phase 3
- [ ] Multi-chain support (Ethereum, Polygon)
- [ ] Cross-chain agent coordination
- [ ] Decentralized agent network
- [ ] Agent marketplace

---

## Summary

The ICB Agent Swarm is the **most agentic DeFi project** with:

✅ **10 specialized agents** working autonomously
✅ **Hierarchical coordination** via orchestrator
✅ **AI-powered decision making** (OpenRouter)
✅ **Micropayments** for API access (x402)
✅ **High-frequency operations** (MagicBlock ER)
✅ **Consensus voting** for critical decisions
✅ **Automated workflows** for all operations
✅ **Real-time monitoring** and alerting
✅ **Machine learning** for continuous improvement

**Result**: Fully autonomous monetary policy management with minimal human intervention! 🤖🚀
