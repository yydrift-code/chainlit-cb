#!/bin/bash

echo "🔐 Fixing Let's Encrypt ACME file permissions..."

# Check if letsencrypt directory exists
if [ ! -d "letsencrypt" ]; then
    echo "❌ Error: letsencrypt directory not found!"
    exit 1
fi

# Create acme.json if it doesn't exist
if [ ! -f "letsencrypt/acme.json" ]; then
    echo "📝 Creating acme.json file..."
    touch letsencrypt/acme.json
fi

# Set proper ownership and permissions
echo "🔑 Setting proper permissions..."
sudo chown -R $USER:$USER letsencrypt
chmod 600 letsencrypt
chmod 600 letsencrypt/acme.json

echo "✅ Permissions fixed!"
echo "   - letsencrypt directory: 600"
echo "   - acme.json file: 600"
echo ""
echo "📝 You can now restart Traefik:"
echo "   docker compose -f docker-compose.production.yml restart traefik"
