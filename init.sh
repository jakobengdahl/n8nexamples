#install n8n
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18
npm install -g n8n
n8n start

#add API-keys
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
}]
EOF

n8n import:credentials --input=credentials.json --overwrite=true

