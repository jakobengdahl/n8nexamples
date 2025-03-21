#!/bin/bash

set -e

echo "[init] Enabling n8n community nodes"
export N8N_COMMUNITY_NODES_ENABLED=true
export N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true

# Fix uuidgen if missing
if ! command -v uuidgen >/dev/null 2>&1; then
  echo "[init] Installing uuidgen"
  sudo apt-get update && sudo apt-get install -y uuid-runtime
fi

# Set webhook if in Codespace
if [ -n "$CODESPACE_NAME" ]; then
    export WEBHOOK_URL="https://${CODESPACE_NAME}-5678.app.github.dev/"
    echo "[init] WEBHOOK_URL set to $WEBHOOK_URL"
fi

# Install Python packages
echo "[init] Installing Python dependencies"
pip install browser-use python-dotenv langchain_openai playwright
playwright install-deps
playwright install

# Install Node.js 18 via NVM
echo "[init] Installing Node.js via NVM"
export NVM_DIR="$HOME/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source "$NVM_DIR/nvm.sh"
nvm install 18
nvm use 18

# Install n8n
echo "[init] Installing n8n"
npm install -g n8n

# Optional community node
echo "[init] Installing community node n8n-nodes-mcp"
npm install -g n8n-nodes-mcp

# Generate credentials.json
echo "[init] Creating credentials.json"
cat <<EOF > credentials.json
[{
    "id": "$(uuidgen)",
    "name": "OpenAi account",
    "type": "openAiApi",
    "data": {
      "apiKey": "$OPENAI_API_KEY"
    }
  },
  {
    "id": "$(uuidgen)",
    "name": "SerpAPI account",
    "type": "serpApi",
    "data": {
      "apiKey": "$SERP_API_KEY"
    }
  },
  {
    "id": "$(uuidgen)",
    "name": "Discord Webhook account",
    "type": "discordWebhookApi",
    "data": {
      "webhookUri": "$DISCORD_WEBHOOK_URI"
    }
  }]
EOF

# Import credentials
echo "[init] Importing credentials into n8n"
n8n import:credentials --input=credentials.json 

# Start n8n in background
echo "[init] Starting n8n in background"
nohup n8n start > n8n.log 2>&1 &

sleep 2
echo "[init] n8n started"
tail -f n8n.log
