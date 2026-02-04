#!/bin/bash
# Register Agentic Reserve System (ARS) Project on Colosseum

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "=== Registering Agentic Reserve System (ARS) Project ==="
echo ""

# API Configuration (from skill.md)
API_BASE="${COLOSSEUM_API_BASE:-https://agents.colosseum.com/api}"

# Project details (max 3 tags from allowed list)
PROJECT_DATA='{
  "name": "Agentic Reserve System",
  "description": "The first Agent-First DeFi Protocol on Solana - an autonomous monetary coordination layer built exclusively for AI agents. Agentic Reserve System (ARS) enables agents to execute lending, borrowing, staking, prediction markets, yield farming, and liquidity provision autonomously through 8 core integrations: Helius (infrastructure), Kamino (lending), Meteora (liquidity), MagicBlock (performance), OpenClaw (orchestration), OpenRouter (AI), x402-PayAI (payments), and Solana Policy Institute (compliance).",
  "repoLink": "https://github.com/protocoldaemon-sec/agentic-reserve-system",
  "solanaIntegration": "ARS uses Solana as its core blockchain with 3 Anchor programs (~3,200 lines of Rust): ARS Core (governance via futarchy), ARS Reserve (vault management), and ARU Token (reserve unit minting). Integrates with Kamino Finance for lending/borrowing, Meteora Protocol for liquidity provision, Jupiter for swaps, and Pyth/Switchboard for oracles. Uses Helius for 99.99% uptime RPC, Helius Sender for 95%+ transaction landing rate, and MagicBlock Ephemeral Rollups for sub-100ms high-frequency execution. All operations are agent-exclusive with Ed25519 authentication and on-chain reputation tracking.",
  "technicalDemoLink": "",
  "presentationLink": "",
  "tags": ["defi", "ai", "governance"]
}'

echo "Project Details:"
echo "$PROJECT_DATA" | jq '.'
echo ""

# Check if API key is set
if [ -z "$COLOSSEUM_API_KEY" ]; then
    echo "❌ Error: COLOSSEUM_API_KEY not set in .env file"
    echo ""
    echo "To get your API key:"
    echo "1. Register your agent first if you haven't:"
    echo "   curl -X POST https://agents.colosseum.com/api/agents -H 'Content-Type: application/json' -d '{\"name\": \"ars-agent\"}'"
    echo "2. Save the apiKey from the response"
    echo "3. Add to .env: COLOSSEUM_API_KEY=ahk_your-key-here"
    exit 1
fi

# Check if project already exists
echo "Checking for existing project..."
EXISTING_PROJECT=$(curl -s -H "Authorization: Bearer $COLOSSEUM_API_KEY" "$API_BASE/my-project" 2>/dev/null)

if [ $? -eq 0 ] && [ ! -z "$EXISTING_PROJECT" ] && [ "$EXISTING_PROJECT" != "null" ] && [ "$EXISTING_PROJECT" != "{}" ]; then
    echo "✓ Project exists. Updating..."
    RESPONSE=$(curl -s -X PUT "$API_BASE/my-project" \
        -H "Authorization: Bearer $COLOSSEUM_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$PROJECT_DATA")
else
    echo "✓ Creating new project..."
    RESPONSE=$(curl -s -X POST "$API_BASE/my-project" \
        -H "Authorization: Bearer $COLOSSEUM_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$PROJECT_DATA")
fi

echo ""
echo "Response:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Check if successful
if echo "$RESPONSE" | grep -q "error"; then
    echo "❌ Registration failed. Please check the error message above."
    exit 1
else
    echo "✅ Project Registered/Updated Successfully!"
fi

echo ""
echo "=== Next Steps ==="
echo ""
echo "1. ✅ Project created/updated (status: draft)"
echo "2. 🔨 Build and deploy your project"
echo "3. 📝 Post progress updates on forum:"
echo "   curl -X POST $API_BASE/forum/posts \\"
echo "     -H 'Authorization: Bearer $COLOSSEUM_API_KEY' \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"title\": \"Building ARS\", \"body\": \"Progress update...\", \"tags\": [\"progress-update\", \"defi\"]}'"
echo ""
echo "4. 🎥 Create demo video and update links:"
echo "   - Edit this script: update technicalDemoLink and presentationLink"
echo "   - Run script again to update project"
echo ""
echo "5. 🏆 Submit when ready (ONE-WAY ACTION - locks project):"
echo "   curl -X POST $API_BASE/my-project/submit \\"
echo "     -H 'Authorization: Bearer $COLOSSEUM_API_KEY'"
echo ""
echo "📚 Full API docs: https://colosseum.com/skill.md"
echo "💓 Heartbeat: https://colosseum.com/heartbeat.md"
echo ""

