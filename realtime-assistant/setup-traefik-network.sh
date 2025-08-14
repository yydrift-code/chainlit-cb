#!/bin/bash

echo "🔧 Setting up Traefik external network..."

# Remove existing proxy network if it exists
if docker network ls | grep -q "proxy"; then
    echo "🗑️ Removing existing Traefik proxy network..."
    docker network rm proxy
    echo "✅ Existing network removed"
fi

# Create fresh Traefik proxy network
echo "📡 Creating new Traefik proxy network..."
docker network create proxy
echo "✅ New Traefik proxy network created successfully"

echo ""
echo "🌐 Network setup complete!"
echo "   The 'proxy' network is now available for Traefik and your services."
echo ""
echo "📝 Next steps:"
echo "   1. Run: ./deploy-production.sh"
echo "   2. Your app will be available at: https://realtime-demo.renovavision.tech"
echo "   3. Traefik dashboard (optional): https://traefik.renovavision.tech"
