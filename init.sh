#!/bin/bash
{

  export N8N_COMMUNITY_NODES_ENABLED=true
  export N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true

  set -e

  # If CODESPACE_NAME is set, configure WEBHOOK_URL accordingly
  if [ -n "$CODESPACE_NAME" ]; then
      export WEBHOOK_URL="https://${CODESPACE_NAME}-5678.app.github.dev/"
      echo "WEBHOOK_URL set to $WEBHOOK_URL"
  fi

  # For browser-use
  pip install browser-use
  pip install python-dotenv
  pip install langchain_openai
  pip install playwright
  playwright install-deps
  playwright install


  # Define where NVM should be installed
  export NVM_DIR="$HOME/.nvm"

  # Install NVM
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

  # Load NVM in this script
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

  # Install and use Node.js 18 via NVM
  nvm install 18
  nvm use 18

  # Install n8n
  npm install -g n8n


  # Generate credentials.json
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



  # Import credentials into n8n
  n8n import:credentials --input=credentials.json 
  
  npm i n8n-nodes-mcp

  # Start n8n in background
  nohup n8n start > n8n.log 2>&1 &
} > /tmp/n8n-install.log 2>&1 &

exit 0
