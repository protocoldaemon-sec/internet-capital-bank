# Quick Start - Local Development

This guide will help you run the Agentic Reserve System (ARS) locally on your machine.

## Prerequisites

Before starting, make sure you have:

1. **Node.js** (v18 or higher)
   - Download: https://nodejs.org/
   - Check: `node --version`

2. **Redis** (optional but recommended)
   - Windows: https://github.com/microsoftarchive/redis/releases
   - Mac: `brew install redis`
   - Linux: `sudo apt-get install redis-server`
   - Check: `redis-cli ping` (should return "PONG")

3. **Git** (for cloning)
   - Download: https://git-scm.com/

## Quick Start (Windows)

### Option 1: Using Start Script (Recommended)

1. Open Command Prompt or PowerShell
2. Navigate to project directory:
   ```cmd
   cd path\to\agentic-reserve-system
   ```

3. Run the start script:
   ```cmd
   start-local.cmd
   ```

4. The script will:
   - Check dependencies
   - Install npm packages if needed
   - Start backend (port 3000)
   - Start frontend (port 5173)
   - Open browser automatically

### Option 2: Manual Start

1. **Start Redis** (if installed):
   ```cmd
   redis-server
   ```

2. **Start Backend**:
   ```cmd
   cd backend
   npm install
   npm run dev
   ```

3. **Start Frontend** (in new terminal):
   ```cmd
   cd frontend
   npm install
   npm run dev
   ```

4. Open browser: http://localhost:5173

## Quick Start (Mac/Linux)

### Option 1: Using Start Script (Recommended)

1. Open Terminal
2. Navigate to project directory:
   ```bash
   cd path/to/agentic-reserve-system
   ```

3. Make script executable:
   ```bash
   chmod +x start-local.sh
   ```

4. Run the start script:
   ```bash
   ./start-local.sh
   ```

5. The script will:
   - Check dependencies
   - Install npm packages if needed
   - Start Redis if not running
   - Start backend (port 3000)
   - Start frontend (port 5173)

### Option 2: Manual Start

1. **Start Redis**:
   ```bash
   redis-server --daemonize yes
   ```

2. **Start Backend**:
   ```bash
   cd backend
   npm install
   npm run dev
   ```

3. **Start Frontend** (in new terminal):
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

4. Open browser: http://localhost:5173

## Verify Installation

Once everything is running, verify the services:

### 1. Backend API

Open http://localhost:3000 in your browser or use curl:

```bash
# Check ILI
curl http://localhost:3000/ili/current

# Check ICR
curl http://localhost:3000/icr/current

# Check Reserve State
curl http://localhost:3000/reserve/state

# Check Proposals
curl http://localhost:3000/proposals
```

### 2. Frontend Dashboard

Open http://localhost:5173 in your browser. You should see:
- ILI Heartbeat visualization
- ICR Display
- Reserve Chart
- Revenue Metrics
- Staking Metrics
- Oracle Status

### 3. Redis (if installed)

```bash
redis-cli ping
# Should return: PONG
```

## Troubleshooting

### Port Already in Use

If you get "port already in use" errors:

**Backend (Port 3000)**:
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:3000 | xargs kill -9
```

**Frontend (Port 5173)**:
```bash
# Windows
netstat -ano | findstr :5173
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:5173 | xargs kill -9
```

### Redis Not Running

If Redis is not installed or not running:
- The backend will still work but caching will be disabled
- Some features may be slower
- Install Redis for optimal performance

### Dependencies Not Installing

If `npm install` fails:

1. Clear npm cache:
   ```bash
   npm cache clean --force
   ```

2. Delete node_modules and package-lock.json:
   ```bash
   # Backend
   cd backend
   rm -rf node_modules package-lock.json
   npm install
   
   # Frontend
   cd frontend
   rm -rf node_modules package-lock.json
   npm install
   ```

3. Try using yarn instead:
   ```bash
   npm install -g yarn
   yarn install
   ```

### Backend API Errors

If backend shows errors:

1. Check environment variables in `backend/.env`
2. Ensure Supabase credentials are correct
3. Check Redis connection
4. View logs: `tail -f logs/backend.log` (Mac/Linux)

### Frontend Not Loading

If frontend doesn't load:

1. Check `frontend/.env` has correct API URL
2. Ensure backend is running on port 3000
3. Clear browser cache
4. Try incognito/private mode
5. View logs: `tail -f logs/frontend.log` (Mac/Linux)

## Development Workflow

### Running Tests

**Backend Tests**:
```bash
cd backend
npm test
```

**Integration Tests**:
```bash
cd backend
npm run test:integration
```

**Property-Based Tests**:
```bash
cd backend
npm run test:properties
```

### Building for Production

**Backend**:
```bash
cd backend
npm run build
npm start
```

**Frontend**:
```bash
cd frontend
npm run build
npm run preview
```

### Viewing Logs

**Backend Logs**:
```bash
# Mac/Linux
tail -f logs/backend.log

# Windows
type logs\backend.log
```

**Frontend Logs**:
```bash
# Mac/Linux
tail -f logs/frontend.log

# Windows
type logs\frontend.log
```

## Stopping Services

### Using Start Script

Press `Ctrl+C` in the terminal where the script is running.

### Manual Stop

**Windows**:
- Close the terminal windows
- Or use Task Manager to end Node.js processes

**Mac/Linux**:
```bash
# Kill backend
kill $(cat logs/backend.pid)

# Kill frontend
kill $(cat logs/frontend.pid)

# Stop Redis
redis-cli shutdown
```

## Environment Variables

### Backend (.env)

```env
PORT=3000
NODE_ENV=development
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
REDIS_URL=redis://localhost:6379
SOLANA_RPC_URL=https://api.devnet.solana.com
HELIUS_API_KEY=your_helius_key
```

### Frontend (.env)

```env
VITE_API_URL=http://localhost:3000
VITE_WS_URL=ws://localhost:3000
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
VITE_SOLANA_NETWORK=devnet
```

## Next Steps

Once everything is running:

1. **Explore the Dashboard**: http://localhost:5173
2. **Test the API**: Use curl or Postman to test endpoints
3. **Try the SDK**: See `sdk/README.md` for examples
4. **Run Tests**: Execute integration tests
5. **Read Documentation**: Check `documentation/` folder

## Support

If you encounter issues:

1. Check this troubleshooting guide
2. View logs for error messages
3. Check GitHub Issues: https://github.com/protocoldaemon-sec/agentic-reserve-system/issues
4. Join Discord: https://discord.gg/ars

## Quick Commands Reference

```bash
# Start everything
./start-local.sh          # Mac/Linux
start-local.cmd           # Windows

# Backend only
cd backend && npm run dev

# Frontend only
cd frontend && npm run dev

# Run tests
cd backend && npm test

# Build for production
cd backend && npm run build
cd frontend && npm run build

# View logs
tail -f logs/backend.log   # Mac/Linux
tail -f logs/frontend.log  # Mac/Linux
```

## Architecture Overview

```
┌─────────────────────────────────────────┐
│         Frontend (Port 5173)            │
│    React + TypeScript + Tailwind        │
└──────────────┬──────────────────────────┘
               │ HTTP/WebSocket
               ▼
┌─────────────────────────────────────────┐
│         Backend API (Port 3000)         │
│      Express + TypeScript + Node.js     │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴────────┐
       ▼                ▼
┌─────────────┐  ┌─────────────┐
│   Supabase  │  │    Redis    │
│ (PostgreSQL)│  │   (Cache)   │
└─────────────┘  └─────────────┘
```

Happy coding! 🚀
