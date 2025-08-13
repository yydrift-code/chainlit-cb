#!/bin/bash

echo "🔧 Setting up Traefik external network..."

# Check if the proxy network already exists
if docker network ls | grep -q "proxy"; then
    echo "✅ Traefik proxy network already exists"
else
    echo "📡 Creating Traefik proxy network..."
    docker network create proxy
    echo "✅ Traefik proxy network created successfully"
fi

echo ""
echo "🌐 Network setup complete!"
echo "   The 'proxy' network is now available for Traefik and your services."
echo ""
echo "📝 Next steps:"
echo "   1. Run: ./deploy-production.sh"
echo "   2. Your app will be available at: https://realtime-demo.renovavision.tech"
echo "   3. Traefik dashboard (optional): https://traefik.renovavision.tech"
