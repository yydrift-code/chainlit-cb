#!/bin/bash

# Production deployment script for realtime assistant with Traefik
# This script deploys the app with Traefik reverse proxy and automatic SSL

set -e

echo "🚀 Starting production deployment with Traefik..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Please create .env file with your OPENAI_API_KEY"
    exit 1
fi

# Check if OPENAI_API_KEY is set
if ! grep -q "OPENAI_API_KEY=" .env; then
    echo "❌ Error: OPENAI_API_KEY not found in .env file!"
    exit 1
fi

# Set production public URL
export CHAINLIT_PUBLIC_URL="https://realtime-demo.renovavision.tech"

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p letsencrypt
mkdir -p traefik/dynamic

# Create acme.json file with proper permissions if it doesn't exist
if [ ! -f letsencrypt/acme.json ]; then
    echo "📝 Creating acme.json file..."
    touch letsencrypt/acme.json
    chmod 600 letsencrypt/acme.json
fi

# Set proper permissions for Let's Encrypt
echo "🔐 Setting permissions for Let's Encrypt..."
sudo chown -R $USER:$USER letsencrypt
chmod 600 letsencrypt
chmod 600 letsencrypt/acme.json 2>/dev/null || true

# Setup Traefik network (always recreate for clean setup)
echo "🌐 Setting up Traefik network..."
if docker network ls | grep -q "proxy"; then
    echo "🗑️ Removing existing proxy network..."
    docker network rm proxy
fi
echo "📡 Creating fresh Traefik proxy network..."
docker network create proxy
echo "✅ New Traefik proxy network created"

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker compose down 2>/dev/null || true
docker compose -f docker-compose.production.yml down 2>/dev/null || true

# Build and start production stack
echo "🔨 Building and starting production stack with Traefik..."
docker compose -f docker-compose.production.yml up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 15

# Check service status
echo "📊 Checking service status..."
docker compose -f docker-compose.production.yml ps

# Check Traefik logs
echo "📋 Traefik logs (last 10 lines):"
docker compose -f docker-compose.production.yml logs --tail=10 traefik

# Check realtime assistant logs
echo "📋 Realtime Assistant logs (last 10 lines):"
docker compose -f docker-compose.production.yml logs --tail=10 realtime-assistant

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Your app is now accessible at:"
echo "   $CHAINLIT_PUBLIC_URL"
echo ""
echo "📊 Traefik dashboard (optional):"
echo "   https://traefik.renovavision.tech"
echo ""
echo "📝 Useful commands:"
echo "   View logs: docker compose -f docker-compose.production.yml logs -f"
echo "   Stop: docker compose -f docker-compose.production.yml down"
echo "   Restart: docker compose -f docker-compose.production.yml restart"
echo "   Update: ./deploy-production.sh"
echo ""
echo "🔒 Traefik will automatically:"
echo "   - Obtain SSL certificates from Let's Encrypt"
echo "   - Handle HTTPS termination"
echo "   - Proxy requests to your app"
echo "   - Provide health checks and load balancing"
echo ""
echo "⚠️  Important notes:"
echo "   - Make sure your domain renovavision.tech points to this server"
echo "   - DNS records for realtime-demo.renovavision.tech must be configured"
echo "   - Ports 80 and 443 must be open on your firewall"
