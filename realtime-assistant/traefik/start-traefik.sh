#!/bin/bash

# Script to start Traefik service
# This should be run before starting the main application

set -e

echo "🚀 Starting Traefik service..."

# Check if we're in the traefik directory
if [[ ! -f "docker-compose.yml" ]]; then
    echo "❌ Error: This script must be run from the traefik directory!"
    exit 1
fi

# Check if .env file exists in parent directory
if [[ ! -f "../.env" ]]; then
    echo "❌ Error: .env file not found in parent directory!"
    echo "Please create .env file with your ACME_EMAIL variable."
    exit 1
fi

# Create traefik network if it doesn't exist
if ! docker network ls | grep -q "traefik"; then
    echo "🌐 Creating traefik network..."
    docker network create traefik
fi

# Start Traefik
echo "📡 Starting Traefik..."
docker compose up -d

echo "✅ Traefik service started successfully!"
echo "🌐 Traefik dashboard available at: http://localhost:8080"
echo "🔒 HTTPS endpoints will be available once certificates are obtained"
