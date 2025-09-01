#!/bin/bash

# Production deployment script for realtime assistant with Traefik
# This script deploys the app with Traefik reverse proxy and automatic SSL

set -e

echo "🚀 Starting production deployment with Traefik..."

# Check if required files exist
if [[ ! -f ".env" ]]; then
    echo "❌ Error: .env file not found!"
    echo "Please copy .env.template to .env and fill in your values."
    exit 1
fi

if [[ ! -f "docker-compose.prod.yml" ]]; then
    echo "❌ Error: docker-compose.prod.yml file not found!"
    exit 1
fi

if [[ ! -f "traefik/docker-compose.yml" ]]; then
    echo "❌ Error: traefik/docker-compose.yml file not found!"
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

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker compose down 2>/dev/null || true
docker compose -f docker-compose.prod.yml down 2>/dev/null || true
cd traefik && docker compose down 2>/dev/null || true && cd ..

# Setup Traefik network (always recreate for clean setup)
echo "🌐 Setting up Traefik network..."
if docker network ls | grep -q "proxy"; then
    echo "🗑️ Removing existing proxy network..."
    docker network rm proxy
fi
echo "📡 Creating fresh Traefik proxy network..."
docker network create proxy
echo "✅ New Traefik proxy network created"

# Start Traefik first
echo "🚀 Starting Traefik service..."
cd traefik
docker compose up -d
cd ..

# Wait for Traefik to be ready
echo "⏳ Waiting for Traefik to be ready..."
sleep 10

# Build and start production stack
echo "🔨 Building and starting production stack..."
docker compose -f docker-compose.prod.yml up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 15

# Check service status
echo "📊 Checking service status..."
docker compose -f docker-compose.prod.yml ps

# Check Traefik logs
echo "📋 Traefik logs (last 10 lines):"
cd traefik && docker compose logs --tail=10 && cd ..

# Check realtime assistant logs
echo "📋 Realtime Assistant logs (last 10 lines):"
docker compose -f docker-compose.prod.yml logs --tail=10 realtime-assistant

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌍 Your services should be available at:"
echo "   - Realtime Assistant: https://realtime-demo.renovavision.tech"
echo "   - Traefik Dashboard: https://traefik.renovavision.tech"
echo ""
echo "📊 Traefik dashboard (optional):"
echo "   https://traefik.renovavision.tech"
echo ""
echo "📝 Useful commands:"
echo "   View logs: docker compose -f docker-compose.prod.yml logs -f"
echo "   Stop: docker compose -f docker-compose.prod.yml down"
echo "   Restart: docker compose -f docker-compose.prod.yml restart"
echo "   Update: ./deploy-production.sh"
echo "   Start Traefik only: cd traefik && ./start-traefik.sh"
echo "   Stop Traefik only: cd traefik && ./stop-traefik.sh"
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