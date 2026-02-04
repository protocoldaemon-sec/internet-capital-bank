# OpenClaw Setup for ICB Project

**Status:** ✅ INSTALLED & RUNNING  
**Version:** OpenClaw 2026.1.30  
**Dashboard:** http://127.0.0.1:18789  
**Gateway:** Running as Windows Scheduled Task

---

## Quick Start

### Start Gateway

```powershell
# Gateway runs automatically as scheduled task
# To manually start/stop:
schtasks /Run /TN "OpenClaw Gateway"
schtasks /End /TN "OpenClaw Gateway"

# Or run in foreground
openclaw gateway
```

### Open Dashboard

```powershell
openclaw dashboard --token
```

### Check Status

```powershell
openclaw status
```

---

## Configuration

**Main Config:** `C:\Users\raden\.openclaw\openclaw.json`

**Key Settings:**
- Model: `openrouter/anthropic/claude-sonnet-4-5`
- Gateway: `ws://127.0.0.1:18789`
- WhatsApp: Connected (+6285161740419)

**Project Config:** `.openclaw/config.json`

Agents configured for ICB:
- `solana-dev` - Solana/Anchor development
- `defi-integration` - DeFi protocol integration
- `oracle-agent` - ILI/ICR calculation
- `testing-agent` - Testing & QA

---

## Usage

### Via Global CLI

```powershell
openclaw status
openclaw dashboard --token
openclaw logs --follow
```

### Via npm (after `npm install`)

```powershell
npm run openclaw:gateway
npm run openclaw:dashboard
npm run openclaw -- status
```

---

## Environment Variables

Add to `.env`:

```properties
# OpenClaw Configuration
OPENCLAW_GATEWAY_URL=ws://127.0.0.1:18789
OPENCLAW_DASHBOARD_URL=http://127.0.0.1:18789
OPENCLAW_CONFIG_PATH=.openclaw/config.json
```

---

## Troubleshooting

### Gateway not running

```powershell
schtasks /Run /TN "OpenClaw Gateway"
```

### Port already in use

```powershell
netstat -ano | findstr :18789
taskkill /PID <PID> /F
```

### Token mismatch

Edit `C:\Users\raden\.openclaw\openclaw.json` and ensure `gateway.auth.token` is set correctly.

---

## Resources

- **Docs:** https://docs.openclaw.ai
- **Install:** https://docs.openclaw.ai/install
- **Troubleshooting:** https://docs.openclaw.ai/troubleshooting

---

**Last Updated:** February 4, 2026 23:00 WIB
