#!/bin/bash

# Define where NVM should be installed
export NVM_DIR="$HOME/.nvm"

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Load NVM in this script
# (so that 'nvm' becomes available immediately)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Install and use Node.js 18 via NVM
nvm install 18
nvm use 18

# Install n8n
npm install -g n8n

# Generate credentials.json
cat <<EOF > credentials.json
[{
  "name": "OpenAi account",
  "type": "openAiApi",
  "data": {
    "apiKey": "$OPENAI_API_KEY"
  }
},
{
  "name": "SerpAPI account",
  "type": "serpApi",
  "data": {
    "apiKey": "$SERP_API_KEY"
  }
},
{
  "name": "Discord Webhook account",
  "type": "discordWebhookApi",
  "data": {
    "webhookUri": "$DISCORD_WEBHOOK_URI"
  }
}]
EOF

# Import credentials into n8n
n8n import:credentials --input=credentials.json --overwrite=true

# Start n8n
n8n start
