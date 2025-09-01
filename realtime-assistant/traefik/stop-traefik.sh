#!/bin/bash

# Script to stop Traefik service

set -e

echo "🛑 Stopping Traefik service..."

# Check if we're in the traefik directory
if [[ ! -f "docker-compose.yml" ]]; then
    echo "❌ Error: This script must be run from the traefik directory!"
    exit 1
fi

# Stop Traefik
echo "📡 Stopping Traefik..."
docker compose down

echo "✅ Traefik service stopped successfully!"
