#!/bin/bash

# Production deployment script for realtime-demo.renovavision.tech
# This script sets up Caddy reverse proxy with your realtime assistant

set -e

echo "🚀 Starting production deployment..."

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

# Create log directory for Caddy
echo "📁 Creating log directory..."
sudo mkdir -p /var/log/caddy
sudo chown $USER:$USER /var/log/caddy

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker compose down 2>/dev/null || true
docker compose -f docker-compose.production.yml down 2>/dev/null || true

# Build and start production stack
echo "🔨 Building and starting production stack..."
docker compose -f docker-compose.production.yml up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service status
echo "📊 Checking service status..."
docker compose -f docker-compose.production.yml ps

# Check Caddy logs
echo "📋 Caddy logs (last 10 lines):"
docker compose -f docker-compose.production.yml logs --tail=10 caddy

# Check realtime assistant logs
echo "📋 Realtime Assistant logs (last 10 lines):"
docker compose -f docker-compose.production.yml logs --tail=10 realtime-assistant

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Your app is now accessible at:"
echo "   https://realtime-demo.renovavision.tech"
echo ""
echo "📝 Useful commands:"
echo "   View logs: docker compose -f docker-compose.production.yml logs -f"
echo "   Stop: docker compose -f docker-compose.production.yml down"
echo "   Restart: docker compose -f docker-compose.production.yml restart"
echo "   Update: ./deploy-production.sh"
echo ""
echo "🔒 Caddy will automatically:"
echo "   - Obtain SSL certificates from Let's Encrypt"
echo "   - Handle HTTPS termination"
echo "   - Proxy requests to your app"
echo "   - Provide health checks and load balancing"
