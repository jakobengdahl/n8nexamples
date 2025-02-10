#!/bin/bash

# Install NVM and Node.js 18
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18

# Install n8n
npm install -g n8n

# Generate credentials.json from environment variables
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