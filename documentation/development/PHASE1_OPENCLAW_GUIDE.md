# Phase 1: Project Initialization with OpenClaw

## Overview

Use OpenClaw agents to accelerate Phase 1 setup. This guide shows how to leverage the configured agents to scaffold the ICB project structure.

---

## Prerequisites

✅ OpenClaw gateway running
✅ 4 agents configured (solana-dev, defi-integration, oracle-agent, testing-agent)
✅ Dashboard accessible at http://127.0.0.1:18789

---

## Task 1.1: Initialize Monorepo Structure

**Use OpenClaw to scaffold the project:**

```bash
# Open OpenClaw dashboard
openclaw dashboard --token

# Or use CLI
openclaw agent send solana-dev "Create a monorepo structure for ICB with:
- backend/ (TypeScript/Express API)
- frontend/ (Vite + React + TypeScript)
- programs/ (Solana/Anchor smart contracts)
- shared/ (shared types and utilities)

Include:
- Root package.json with workspace configuration
- .gitignore for Node.js, Rust, and Solana
- README.md with project overview
- tsconfig.json for TypeScript projects
"
```

**Expected Output:**
```
internet-capital-bank/
├── backend/
├── frontend/
├── programs/
├── shared/
├── package.json
├── .gitignore
├── README.md
└── tsconfig.json
```

---

## Task 1.2: Initialize Anchor Workspace

**Use solana-dev agent:**

```bash
openclaw agent send solana-dev "Initialize Anchor workspace with three programs:
1. icb-core (governance, ILI oracle, futarchy)
2. icb-reserve (vault management, rebalancing)
3. icb-token (ICU token mint/burn)

Configure Anchor.toml for:
- Devnet cluster
- Program IDs
- Test validator settings
- Solana version 1.18+

Create lib.rs stubs for each program with:
- Basic module structure
- Error codes
- State accounts
- Instruction handlers
"
```

**Expected Output:**
```
programs/
├── icb-core/
│   ├── Cargo.toml
│   └── src/
│       ├── lib.rs
│       ├── state.rs
│       ├── errors.rs
│       └── instructions/
├── icb-reserve/
│   ├── Cargo.toml
│   └── src/
├── icb-token/
│   ├── Cargo.toml
│   └── src/
├── Anchor.toml
└── Cargo.toml
```

---

## Task 1.3: Set Up Express.js Backend

**Use defi-integration agent (handles backend setup):**

```bash
openclaw agent send defi-integration "Create Express.js backend with TypeScript:

Structure:
- src/
  - server.ts (main entry point)
  - config/ (environment, database)
  - routes/ (API endpoints)
  - services/ (business logic)
  - models/ (database models)
  - middleware/ (auth, logging, error handling)
  - utils/ (helpers)

Include:
- package.json with dependencies:
  - express, typescript, ts-node, nodemon
  - @supabase/supabase-js, redis, ioredis
  - cors, helmet, express-rate-limit
  - dotenv, winston (logging)
- tsconfig.json for Node.js
- nodemon.json for development
- .env.example with all required variables
- Basic health check endpoint (GET /health)
"
```

**Expected Output:**
```
backend/
├── src/
│   ├── server.ts
│   ├── config/
│   ├── routes/
│   ├── services/
│   ├── models/
│   ├── middleware/
│   └── utils/
├── package.json
├── tsconfig.json
├── nodemon.json
└── .env.example
```

---

## Task 1.4: Set Up Supabase + Redis with Docker

**Use oracle-agent (handles infrastructure):**

```bash
openclaw agent send oracle-agent "Create Docker Compose setup for ICB infrastructure:

Services:
1. Supabase (PostgreSQL + PostgREST + Realtime)
   - Port 5432 (PostgreSQL)
   - Port 3000 (PostgREST API)
   - Port 4000 (Realtime)
   - Enable Row Level Security
   - Create initial schema:
     - ili_snapshots (timestamp, value, components)
     - icr_snapshots (timestamp, value, confidence)
     - proposals (id, type, params, votes, status)
     - revenue_events (timestamp, type, amount, agent_id)
     - agent_staking (agent_id, staked_amount, rewards)

2. Redis
   - Port 6379
   - Persistence enabled
   - Max memory 256MB

3. Redis Commander (optional, for debugging)
   - Port 8081

Include:
- docker-compose.yml
- .env.docker with default credentials
- init.sql for database schema
- Health checks for all services
- Volume mounts for persistence
"
```

**Expected Output:**
```
backend/
├── docker-compose.yml
├── .env.docker
└── database/
    └── init.sql
```

---

## Task 1.5: Initialize Vite + React Frontend

**Use defi-integration agent:**

```bash
openclaw agent send defi-integration "Create Vite + React + TypeScript frontend:

Structure:
- src/
  - main.tsx (entry point)
  - App.tsx (root component)
  - components/ (reusable UI components)
  - pages/ (Dashboard, Proposals, History, Reserve, Docs)
  - hooks/ (custom React hooks)
  - services/ (API clients)
  - utils/ (helpers)
  - types/ (TypeScript types)
  - styles/ (global CSS)

Include:
- package.json with dependencies:
  - react, react-dom, react-router-dom
  - @solana/wallet-adapter-react
  - @solana/wallet-adapter-wallets
  - recharts (for charts)
  - axios (for API calls)
  - tailwindcss, postcss, autoprefixer
- vite.config.ts with:
  - React plugin
  - Path aliases (@/ for src/)
  - Proxy for backend API
- tsconfig.json for React
- index.html
- Basic routing setup
"
```

**Expected Output:**
```
frontend/
├── src/
│   ├── main.tsx
│   ├── App.tsx
│   ├── components/
│   ├── pages/
│   ├── hooks/
│   ├── services/
│   ├── utils/
│   ├── types/
│   └── styles/
├── public/
├── package.json
├── vite.config.ts
├── tsconfig.json
└── index.html
```

---

## Task 1.6: Configure Tailwind CSS

**Use defi-integration agent:**

```bash
openclaw agent send defi-integration "Configure Tailwind CSS for ICB frontend:

Setup:
- Install tailwindcss, postcss, autoprefixer
- Create tailwind.config.js with:
  - Custom color palette (primary, secondary, accent)
  - Custom fonts (Inter for UI, JetBrains Mono for code)
  - Dark mode support
  - Custom breakpoints
  - Animation utilities
- Create postcss.config.js
- Create src/styles/index.css with:
  - Tailwind directives
  - Custom CSS variables
  - Global styles
  - Utility classes

Include ICB-specific design tokens:
- Colors: Federal Reserve inspired (navy, gold, white)
- Typography: Professional, readable
- Spacing: Consistent 8px grid
- Shadows: Subtle depth
"
```

**Expected Output:**
```
frontend/
├── tailwind.config.js
├── postcss.config.js
└── src/
    └── styles/
        └── index.css
```

---

## Verification Steps

After OpenClaw generates the structure:

### 1. Verify Monorepo Structure

```bash
# Check directory structure
ls -la

# Should see:
# backend/
# frontend/
# programs/
# shared/
# package.json
```

### 2. Install Dependencies

```bash
# Root workspace
npm install

# Backend
cd backend && npm install

# Frontend
cd frontend && npm install

# Anchor programs
cd programs && anchor build
```

### 3. Start Services

```bash
# Start Docker services
cd backend && docker-compose up -d

# Verify services are running
docker ps

# Start backend
cd backend && npm run dev

# Start frontend
cd frontend && npm run dev
```

### 4. Test Health Checks

```bash
# Backend health check
curl http://localhost:3001/health

# Frontend
open http://localhost:5173

# Supabase
curl http://localhost:3000/

# Redis
redis-cli ping
```

---

## OpenClaw Automation Tips

### Use Cron Jobs for Repetitive Tasks

```bash
# Auto-format code every hour
openclaw cron create "0 * * * *" "npm run format" --name "code-formatter"

# Run tests every 30 minutes
openclaw cron create "*/30 * * * *" "npm test" --name "test-runner"
```

### Set Up Webhooks for Monitoring

```bash
# Monitor build failures
openclaw hooks create build-monitor --event "build:failed" --action "notify-team"

# Monitor deployment
openclaw hooks create deploy-monitor --event "deploy:success" --action "log-deployment"
```

### Use Browser Tools for Testing

```bash
# Test frontend in browser
openclaw browser open http://localhost:5173

# Test wallet connection
openclaw browser test "Connect Phantom wallet and verify connection"
```

---

## Troubleshooting

### Agent Not Responding

```bash
# Check agent status
openclaw agents list

# View agent logs
openclaw logs --agent solana-dev

# Restart agent
openclaw agents restart solana-dev
```

### Gateway Connection Issues

```bash
# Check gateway status
openclaw status

# Restart gateway
schtasks /End /TN "OpenClaw Gateway"
schtasks /Run /TN "OpenClaw Gateway"
```

### Generation Errors

```bash
# View detailed logs
openclaw logs --follow

# Try with different agent
openclaw agent send defi-integration "Same task..."

# Manual fallback
# If agent fails, scaffold manually and ask agent to fill in details
```

---

## Next Steps

After Phase 1 completion:

1. ✅ Verify all services are running
2. ✅ Test health checks
3. ✅ Commit initial structure to git
4. 🔄 Move to Phase 2: Oracle & Data Layer
5. 🔄 Use `oracle-agent` for DeFi integrations

---

## Success Criteria

- [ ] Monorepo structure created
- [ ] Anchor workspace initialized with 3 programs
- [ ] Express backend running on port 3001
- [ ] Supabase + Redis running via Docker
- [ ] Vite frontend running on port 5173
- [ ] Tailwind CSS configured and working
- [ ] All health checks passing
- [ ] Git repository initialized

---

**Ready to build! Use OpenClaw to accelerate every phase.** 🚀
