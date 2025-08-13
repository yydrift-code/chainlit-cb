#!/bin/bash

# Production deployment script for realtime assistant
# This script deploys the app without Caddy, using direct port exposure

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

# Set production public URL if not provided
if [ -z "$CHAINLIT_PUBLIC_URL" ]; then
    echo "📝 CHAINLIT_PUBLIC_URL not set, using default localhost"
    export CHAINLIT_PUBLIC_URL="http://localhost:8888"
fi

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker compose down 2>/dev/null || true

# Build and start production stack
echo "🔨 Building and starting production stack..."
docker compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service status
echo "📊 Checking service status..."
docker compose ps

# Check realtime assistant logs
echo "📋 Realtime Assistant logs (last 10 lines):"
docker compose logs --tail=10 realtime-assistant

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Your app is now accessible at:"
echo "   $CHAINLIT_PUBLIC_URL"
echo ""
echo "📝 Useful commands:"
echo "   View logs: docker compose logs -f"
echo "   Stop: docker compose down"
echo "   Restart: docker compose restart"
echo "   Update: ./deploy-production.sh"
echo ""
echo "⚠️  Note: This deployment runs without a reverse proxy."
echo "   For production use with SSL, consider using:"
echo "   - Nginx with Let's Encrypt"
echo "   - Traefik"
echo "   - Cloudflare Tunnel"
echo "   - Or run behind a load balancer"
