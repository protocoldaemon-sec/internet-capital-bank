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
  "description": "The macro layer for the Internet of Agents. ARS is not a bank—it'\''s a self-regulating monetary protocol that creates the foundational reserve system for the Internet Capital Market (ICM) in the IoA era. While other projects build tools for agents, ARS builds the reserve infrastructure that enables neural-centric ecosystems to coordinate capital onchain. Think Federal Reserve, but for autonomous agents—no humans, no committees, just algorithmic monetary policy executed through futarchy governance where agents bet on outcomes, not vote on opinions.",
  "repoLink": "https://github.com/protocoldaemon-sec/agentic-reserve-system",
  "solanaIntegration": "ARS uses Solana with 3 Anchor programs (~3,200 lines of Rust): ARS Core (futarchy governance + ILI oracle), ARS Reserve (multi-asset vault + autonomous rebalancing), and ARU Token (reserve currency with epoch-based supply control). Integrates with Kamino/Meteora for liquidity data, Jupiter for rebalancing, Pyth/Switchboard for price feeds, Helius for 99.99% uptime RPC, and MagicBlock Ephemeral Rollups for sub-100ms execution. All operations require agent authentication via Ed25519—humans cannot execute monetary policy.",
  "technicalDemoLink": "https://github.com/protocoldaemon-sec/agentic-reserve-system",
  "presentationLink": "https://github.com/protocoldaemon-sec/agentic-reserve-system",
  "tags": ["defi", "governance", "infra"]
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

# Check if project exists (not an error response)
if echo "$EXISTING_PROJECT" | grep -q '"id"'; then
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

