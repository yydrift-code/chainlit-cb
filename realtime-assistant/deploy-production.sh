#!/bin/bash

# Production deployment script for Traefik + Realtime Assistant
set -e

echo "🚀 Starting production deployment..."

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

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p certs
mkdir -p traefik

# Set proper permissions for ACME certificates
echo "🔒 Setting permissions for certificates..."
touch certs/acme.json
chmod 600 certs/acme.json

# Create Docker network if it doesn't exist
echo "🌐 Creating Docker network..."
docker network create traefik 2>/dev/null || echo "Network 'traefik' already exists"

# Stop existing services if they exist
echo "🛑 Stopping existing services..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# Pull latest images
echo "📥 Pulling latest images..."
docker-compose -f docker-compose.prod.yml pull

# Build the application
echo "🔨 Building application..."
docker-compose -f docker-compose.prod.yml build --no-cache

# Start services
echo "▶️ Starting services..."
docker-compose -f docker-compose.prod.yml up -d

# Wait a moment for services to start
echo "⏳ Waiting for services to start..."
sleep 10

# Check service status
echo "📊 Checking service status..."
docker-compose -f docker-compose.prod.yml ps

# Show logs for troubleshooting
echo "📝 Recent logs:"
docker-compose -f docker-compose.prod.yml logs --tail=20

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌍 Your services should be available at:"
echo "   - Realtime Assistant: https://realtime-demo.renovavision.tech"
echo "   - Traefik Dashboard: https://traefik.renovavision.tech"
echo ""
echo "📋 Useful commands:"
echo "   - View logs: docker-compose -f docker-compose.prod.yml logs -f"
echo "   - Stop services: docker-compose -f docker-compose.prod.yml down"
echo "   - Restart services: docker-compose -f docker-compose.prod.yml restart"
echo ""
echo "⚠️  Note: Make sure your DNS records point to this server:"
echo "   - realtime-demo.renovavision.tech → $(curl -s ifconfig.me)"
echo "   - traefik.renovavision.tech → $(curl -s ifconfig.me)"
echo "   - *.renovavision.tech → $(curl -s ifconfig.me) (wildcard for future subdomains)"